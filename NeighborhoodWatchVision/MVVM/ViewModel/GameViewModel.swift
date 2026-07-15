//
//  GameViewModel.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 11/07/26.
//

import SwiftUI
import RealityKit
import RealityKitContent
import Foundation

enum GameState: Equatable {
    case playing
    case won
    case lost(reason: String)
}

@MainActor
@Observable
class GameViewModel {
    var encounterRoot = Entity()
    var worldRoot: Entity?
    var currentEncounterIndex = 0
    var gameState: GameState = .playing
    
    private var encounters: [EncounterData] = []
        
    private var characterCache: [String: Entity] = [:]
    private var idCardCache: [String: Entity] = [:]
    
    var elapsedMinutes: Int = 0
        
    var currentTimeString: String {
        let hours = elapsedMinutes / 60
        let minutes = elapsedMinutes % 60
        return String(format: "%02d.%02d", hours, minutes)
    }
    
    var activeEncounter: EncounterData? {
        guard encounters.indices.contains(currentEncounterIndex) else { return nil }
        return encounters[currentEncounterIndex]
    }
        
    func startGame(with data: [EncounterData]) {
        self.encounters = data.shuffled()
        self.currentEncounterIndex = 0
        self.elapsedMinutes = 0
        self.gameState = .playing
        encounterRoot.children.removeAll()
        Task {
            await preloadCharacters(from: self.encounters)
            if !self.encounters.isEmpty {
                self.spawnEncounter(data: self.encounters[self.currentEncounterIndex])
            }
        }
    }
    
    private func preloadCharacters(from dataList: [EncounterData]) async {
        print("Mulai memuat (preload) karakter 3D...")
        for data in dataList {
            let modelName = data.encounterID
            if characterCache[modelName] == nil {
                do {
                    let templateEntity = try await Entity(named: "Animations/\(modelName)", in: realityKitContentBundle)
                    characterCache[modelName] = templateEntity
                    print("✅ Berhasil memuat karakter: \(modelName)")
                } catch {
                    print("❌ Gagal memuat karakter \(modelName): \(error)")
                }
            }
            
            let idCardName = data.idCardData.idAsset
            if idCardCache[idCardName] == nil {
                do {
                    let templateID = try await Entity(named: "Assets/\(idCardName)", in: realityKitContentBundle)
                    templateID.scale = [0.2, 0.2, 0.2]
                    
                    idCardCache[idCardName] = templateID
                    print("✅ Berhasil memuat ID Card: \(idCardName)")
                } catch {
                    print("❌ Gagal memuat ID Card \(idCardName): \(error)")
                }
            }
        }
        print("Preload selesai.")
    }
    
    func restartGame() {
        print("Merestart Game...")
        
        encounterRoot.children.removeAll()
            
        if let world = worldRoot,
            let leftGate = world.findEntity(named: "Left_Gate"),
            var leftGateComp = leftGate.components[GateComponent.self],
            let rightGate = world.findEntity(named: "Right_Gate"),
            var rightGateComp = rightGate.components[GateComponent.self] {
                
            leftGateComp.state = .closed
            rightGateComp.state = .closed
                
            leftGate.transform.rotation = leftGateComp.closedRotation
            rightGate.transform.rotation = rightGateComp.closedRotation
                
            leftGate.components.set(leftGateComp)
            rightGate.components.set(rightGateComp)
        }
        startGame(with: self.encounters)
    }
    
    func handleButtonPress(entityName: String) {
        print("Button pressed: \(entityName)")
        for npc in encounterRoot.children {
            print("npc in encounterRoot \(npc.name)")
            if var encounterComp = npc.components[ActiveEncounterComponent.self],
                encounterComp.state == .interrogated {
                    
                let isAnomaly = encounterComp.data.llmPromptContext.roleType == .anomaly
                    
                if entityName == "GateButton" || entityName == "export3dcoat_001" {
                    encounterComp.state = .entered
                    npc.components.set(encounterComp)
                        
                    notifyTimeline("Pass")
                    animateGates()
                        
                    if isAnomaly {
                        gameState = .lost(reason: "Kamu membiarkan anomali masuk ke dalam perumahan!")
                        return
                    }
                }
                else if entityName == "AlarmButton" || entityName == "export3dcoat" {
                    notifyTimeline("Out")
                    encounterComp.state = .dismissed
                    npc.components.set(encounterComp)
                }
                    
                Task {
                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                    npc.removeFromParent()
                    spawnNextEncounter()
                }
                break
            }
        }
    }
    
    private func animateGates() {
        guard let world = worldRoot,
              let rightGate = world.findEntity(named: "Right_Gate"),
              var rightGateComp = rightGate.components[GateComponent.self],
              let leftGate = world.findEntity(named: "Left_Gate"),
              var leftGateComp = leftGate.components[GateComponent.self] else {
            return
        }
        
        leftGateComp.state = .opening
        rightGateComp.state = .opening
        
        leftGate.components.set(leftGateComp)
        rightGate.components.set(rightGateComp)
        
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            if var currentLeftComp = leftGate.components[GateComponent.self],
               var currentRightComp = rightGate.components[GateComponent.self] {
                
                currentLeftComp.state = .closing
                currentRightComp.state = .closing
                
                leftGate.components.set(currentLeftComp)
                rightGate.components.set(currentRightComp)
            }
        }
    }
    
    func handleNpcArrived() {
            for npc in encounterRoot.children {
                if var encounterComp = npc.components[ActiveEncounterComponent.self],
                   encounterComp.state == .walkingToPost {
                    
                    encounterComp.state = .interrogated
                    npc.components.set(encounterComp)
                    print("State NPC \(encounterComp.data.scenarioName) sekarang: Interrogated.")
                    
                    let idAsset = encounterComp.data.idCardData.idAsset
                    if let templateID = idCardCache[idAsset] {
                        let handAnchorWrapper = Entity()
                        handAnchorWrapper.name = "HandAnchorWrapper"
                        handAnchorWrapper.components.set(IDCardHandComponent(chirality: .left))
                        
                        let idCardEntity = templateID.clone(recursive: true)
                        idCardEntity.name = "IDCardEntity"

                        idCardEntity.position = [0.1, 0.07, 0]
                        let rotationX = simd_quatf(angle: -.pi / 2, axis: [1, 0, 0])

                        idCardEntity.orientation = rotationX
                        
                        handAnchorWrapper.addChild(idCardEntity)
                        npc.addChild(handAnchorWrapper)
                        
                        print("✅ Memunculkan ID Card di tangan pemain untuk \(encounterComp.data.scenarioName)")
                    }
                    
                    break
                }
            }
        }
    
    private func spawnNextEncounter() {
            guard case .playing = gameState else { return }
            
            // Naikkan index karakter
            currentEncounterIndex += 1
            
            // Hitung progres waktu (Target: 5 Jam = 300 Menit)
            let progress = Double(currentEncounterIndex) / Double(encounters.count)
            elapsedMinutes = Int(progress * 300.0)
            
            // Cek kondisi menang (Sudah jam 05.00 atau antrean habis)
            if elapsedMinutes >= 300 || currentEncounterIndex >= encounters.count {
                elapsedMinutes = 300 // Kunci di 05.00 agar tidak lebih
                print("Shift selesai! Waktu menunjukkan 05.00.")
                gameState = .won
                return
            }
            
            spawnEncounter(data: encounters[currentEncounterIndex])
        }
    
    private func spawnEncounter(data: EncounterData) {
        let modelName = data.encounterID
        guard let templateEntity = characterCache[modelName] else {
            print("⚠️ Karakter \(modelName) tidak ditemukan di cache. Gagal men-spawn.")
            return
        }
        let npcEntity = templateEntity.clone(recursive: true)
        npcEntity.components.set(ActiveEncounterComponent(
            data: data,
            state: .walkingToPost
        ))
        encounterRoot.addChild(npcEntity)
    }
    
    func notifyTimeline(_ identifier: String) {
        guard let scene = encounterRoot.scene else {
            print("Scene belum tersedia!")
            return
        }
            
        NotificationCenter.default.post(
            name: NSNotification.Name("RealityKit.NotificationTrigger"),
            object: nil,
            userInfo: [
                "RealityKit.NotificationTrigger.Scene": scene,
                "RealityKit.NotificationTrigger.Identifier": identifier
            ]
        )
    }
}

//
//  GameViewModel.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 11/07/26.
//

import SwiftUI
import RealityKit
import RealityKitContent

@MainActor
@Observable
class GameViewModel {
    // MARK: - Game State
    var encounterRoot = Entity()
    var currentEncounterIndex = 0
    var gameState: GameState = .playing
    
    // Simpan referensi antrean encounter
    private var encounters: [EncounterData] = []
    
    // MARK: - Game Loop
    func startGame(with data: [EncounterData]) {
        self.encounters = data.shuffled()
        self.currentEncounterIndex = 0
        self.gameState = .playing
        encounterRoot.children.removeAll()
        
        if !encounters.isEmpty {
            spawnEncounter(data: encounters[currentEncounterIndex])
        }
    }
    
    func handleButtonPress(entityName: String) {
        print("Button pressed")
        for npc in encounterRoot.children {
            if var encounterComp = npc.components[ActiveEncounterComponent.self],
               encounterComp.state == .interrogated {
                print("Ada yg lagi introgated nih")
                let isAnomaly = encounterComp.data.llmPromptContext.roleType == .anomaly
                
                if entityName == "export3dcoat_001" {
                    print("GateButton diklik nih")
                    
                    encounterComp.state = .entered
                    npc.components.set(encounterComp)
                    
                    // 🔄 HADAP 90 DERAJAT (Jalan ke Kiri / Masuk)
                    npc.orientation = simd_quatf(angle: -.pi / 2, axis: SIMD3<Float>(0, 1, 0))
                    
                    // Anomali/Warga masuk ke gerbang (Jalan ke Kiri -> X: -5.0)
                    npc.components.set(MoveToTargetComponent(targetPosition: SIMD3<Float>(-5.0, 0, -5.0), speed: 1.0))
                    
                    // 🎬 MAIN KEMBALI ANIMASI JALAN
                    npc.stopAllAnimations()
                    if let walk = encounterComp.walkAnimation {
                        npc.playAnimation(walk.repeat(duration: .infinity), transitionDuration: 0.5)
                    }
                    
                    if isAnomaly {
                        print("GAME OVER! Anomali berhasil masuk.")
                        gameState = .lost(reason: "Kamu membiarkan anomali masuk ke dalam perumahan!")
                        return
                    }
                    
                    print("Warga valid. Gerbang dibuka.")
                    
                } else if entityName == "export3dcoat" {
                    print("AlarmButton diklik nih")
                    if !isAnomaly {
                        print("Peringatan: Kamu mengusir warga asli!")
                    } else {
                        print("Kerja bagus! Anomali berhasil diusir.")
                    }
                    
                    encounterComp.state = .dismissed
                    npc.components.set(encounterComp)
                    
                    // 🔄 HADAP -90 DERAJAT (Jalan ke Kanan / Balik Arah)
                    npc.orientation = simd_quatf(angle: .pi / 2, axis: SIMD3<Float>(0, 1, 0))
                    
                    // Diusir kembali ke tempat asal/spawn (Jalan ke Kanan -> X: 5.0)
                    npc.components.set(MoveToTargetComponent(targetPosition: SIMD3<Float>(5.0, 0, -5.0), speed: 2.5))
                    
                    // 🎬 MAIN KEMBALI ANIMASI JALAN
                    npc.stopAllAnimations()
                    if let walk = encounterComp.walkAnimation {
                        npc.playAnimation(walk.repeat(duration: .infinity), transitionDuration: 0.5)
                    }
                }
                
                // Tunggu sampai NPC benar-benar dihapus dari scene
                Task {
                    while npc.scene != nil {
                        try? await Task.sleep(nanoseconds: 100_000_000)
                    }
                    spawnNextEncounter()
                }
                break
            }
        }
    }
    
    private func spawnNextEncounter() {
        guard case .playing = gameState else { return }
        
        currentEncounterIndex += 1
        
        if currentEncounterIndex < encounters.count {
            spawnEncounter(data: encounters[currentEncounterIndex])
        } else {
            print("Shift selesai! Waktu menunjukkan 05.00.")
            gameState = .won
        }
    }
    
    private func spawnEncounter(data: EncounterData) {
        Task {
            do {
                let npcEntity = try await Entity(named: "Assets/Fatih", in: realityKitContentBundle)
                npcEntity.position = SIMD3<Float>(5.0, 0, -4.0)
                
                // 🔄 HADAP 90 DERAJAT SAAT PERTAMA KALI SPAWN (Jalan ke Kiri/Pos)
                npcEntity.orientation = simd_quatf(angle: -.pi / 2, axis: SIMD3<Float>(0, 1, 0))
                
                var walkAnim: AnimationResource?
                var idleAnim: AnimationResource?
                
                for anim in npcEntity.availableAnimations {
                    if anim.name == "global scene animation" {
                        walkAnim = anim
                    } else if anim.name == "default subtree animation" {
                        idleAnim = anim
                    }
                }
                
                npcEntity.components.set(ActiveEncounterComponent(
                    data: data,
                    state: .walkingToPost,
                    walkAnimation: walkAnim,
                    idleAnimation: idleAnim
                ))
                
                npcEntity.components.set(MoveToTargetComponent(targetPosition: SIMD3<Float>(0, 0, -4.0), speed: 1.0))
                
                if let walk = walkAnim {
                    npcEntity.playAnimation(walk.repeat())
                }
                
                encounterRoot.addChild(npcEntity)
                
            } catch {
                print("Gagal memuat model atau animasi: \(error)")
            }
        }
    }
}

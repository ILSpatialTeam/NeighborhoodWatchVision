//
//  ImmersiveView.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 06/07/26.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    @Environment(AppModel.self) private var appModel
    
    // Entitas root untuk menampung semua NPC yang di-spawn
    @State private var encounterRoot = Entity()
    
    // Melacak urutan antrean encounter saat ini
    @State private var currentEncounterIndex = 0

    var body: some View {
        RealityView { content in
            // 1. Registrasi ECS Components & Systems sebelum digunakan
            ActiveEncounterComponent.registerComponent()
            MoveToTargetComponent.registerComponent()
            MovementSystem.registerSystem()
            
            // 2. Tambahkan root untuk encounter ke dalam scene
            content.add(encounterRoot)

            setupSecurityDesk(in: encounterRoot)
            
            // 3. Load initial RealityKit content bawaan
            if let immersiveContentEntity = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                content.add(immersiveContentEntity)
                // Put skybox here...
            }
            
            // 4. Ambil data encounters dan mulai game dengan spawn encounter pertama
            if let encounters = appModel.gameData?.encounters, !encounters.isEmpty {
                spawnEncounter(data: encounters[currentEncounterIndex])
            }
        }.gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    let tappedEntity = value.entity
                    handleButtonPress(entityName: tappedEntity.name)
                }
        )
    }
    
    /// Fungsi untuk me-load model dan meng-assign data dari JSON ke Entity
    private func spawnEncounter(data: EncounterData) {
        // TODO: Ganti ini dengan load model 3D beneran dari data.spawnVisuals
        let mesh = MeshResource.generateCylinder(height: 1.8, radius: 0.3)
        let material = SimpleMaterial(color: .blue, isMetallic: false)
        let npcEntity = ModelEntity(mesh: mesh, materials: [material])
        
        // Titik spawn (misal: jauh di depan gerbang)
        npcEntity.position = SIMD3<Float>(0, 0, -5.0)
        
        // Pasang data identitas dan state NPC
        npcEntity.components.set(ActiveEncounterComponent(data: data, state: .walkingToPost))
        
        // Pasang target tujuan (ke depan pos satpam, misal di Z: -1.0)
        npcEntity.components.set(MoveToTargetComponent(
            targetPosition: SIMD3<Float>(0, 0, -1.0),
            speed: 1.0 // Sesuaikan kecepatan jalan
        ))
        
        // Masukkan NPC ke dalam scene
        encounterRoot.addChild(npcEntity)
        print("Spawned encounter: \(data.idCardData.printedName) from scenario: \(data.scenarioName)")
    }
    
    private func setupSecurityDesk(in root: Entity) {
        // Tombol Buka Gerbang (Contoh pakai kotak hijau)
        let gateMesh = MeshResource.generateBox(size: 0.2)
        let gateMaterial = SimpleMaterial(color: .green, isMetallic: false)
        let gateButton = ModelEntity(mesh: gateMesh, materials: [gateMaterial])
        
        gateButton.position = SIMD3<Float>(-0.3, 1.0, -0.6) // Letakkan di jangkauan tangan kiri
        gateButton.name = "GateButton" // Penting untuk identifikasi saat di-tap
        
        // Wajib untuk interaksi VisionOS
        gateButton.components.set(InputTargetComponent())
        gateButton.components.set(CollisionComponent(shapes: [.generateBox(size: [0.2, 0.2, 0.2])]))
        
        // Tombol Alarm (Contoh pakai kotak merah)
        let alarmMesh = MeshResource.generateBox(size: 0.2)
        let alarmMaterial = SimpleMaterial(color: .red, isMetallic: false)
        let alarmButton = ModelEntity(mesh: alarmMesh, materials: [alarmMaterial])
        
        alarmButton.position = SIMD3<Float>(0.3, 1.0, -0.6) // Letakkan di jangkauan tangan kanan
        alarmButton.name = "AlarmButton"
        
        alarmButton.components.set(InputTargetComponent())
        alarmButton.components.set(CollisionComponent(shapes: [.generateBox(size: [0.2, 0.2, 0.2])]))
        
        root.addChild(gateButton)
        root.addChild(alarmButton)
    }
    
    private func handleButtonPress(entityName: String) {
        // Cari NPC yang sedang di depan pos (state: .interrogated)
        // Iterasi children dari encounterRoot untuk menemukan NPC yang aktif
        for npc in encounterRoot.children {
            if var encounterComp = npc.components[ActiveEncounterComponent.self],
               encounterComp.state == .interrogated {
                
                if entityName == "GateButton" {
                    print("Gerbang dibuka. Warga masuk.")
                    encounterComp.state = .entered
                    npc.components.set(encounterComp)
                    
                    // Jalan santai melewati gerbang ke dalam perumahan (misal koordinat Z: 5.0)
                    npc.components.set(MoveToTargetComponent(
                        targetPosition: SIMD3<Float>(0, 0, 5.0),
                        speed: 1.0
                    ))
                    
                } else if entityName == "AlarmButton" {
                    print("Alarm ditekan! Anomali diusir.")
                    encounterComp.state = .dismissed
                    npc.components.set(encounterComp)
                    
                    // Lari cepat kembali ke titik awal/luar gerbang (misal koordinat Z: -10.0)
                    npc.components.set(MoveToTargetComponent(
                        targetPosition: SIMD3<Float>(0, 0, -10.0),
                        speed: 2.5 // Kecepatan ditambah agar terlihat panik/lari
                    ))
                }
                
                // Spawn NPC selanjutnya setelah delay singkat agar game tidak terasa kaku
                Task {
                    try? await Task.sleep(nanoseconds: 2_000_000_000) // Delay 2 detik
                    spawnNextEncounter()
                }
                
                // Keluar dari loop setelah memproses 1 NPC aktif
                break
            }
        }
    }

    private func spawnNextEncounter() {
        currentEncounterIndex += 1
        if let encounters = appModel.gameData?.encounters, currentEncounterIndex < encounters.count {
            spawnEncounter(data: encounters[currentEncounterIndex])
        } else {
            print("Shift selesai! Waktu menunjukkan 05.00.")
            // TODO: Tampilkan UI Menang
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}

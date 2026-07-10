//
//  MovementSystem.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 10/07/26.
//

import RealityKit

public struct MovementSystem: System {
    public init(scene: RealityKit.Scene) { }

    public func update(context: SceneUpdateContext) {
        let deltaTime = Float(context.deltaTime)
        
        // Cari semua entitas yang punya komponen bergerak DAN komponen encounter
        let query = EntityQuery(where: .has(MoveToTargetComponent.self) && .has(ActiveEncounterComponent.self))
        
        for entity in context.entities(matching: query, updatingSystemWhen: .rendering) {
            guard let moveComponent = entity.components[MoveToTargetComponent.self],
                  var encounterComp = entity.components[ActiveEncounterComponent.self] else { continue }
            
            let currentPos = entity.position
            let targetPos = moveComponent.targetPosition
            let direction = targetPos - currentPos
            let distance = length(direction)
            
            if distance > 0.1 {
                // Bergerak menuju target
                let normalizedDirection = direction / distance
                entity.position += normalizedDirection * moveComponent.speed * deltaTime
            } else {
                // Sudah sampai tujuan, hapus komponen pergerakan
                entity.components.remove(MoveToTargetComponent.self)
                
                switch encounterComp.state {
                case .walkingToPost:
                    // NPC sampai di meja satpam
                    encounterComp.state = .interrogated
                    entity.components.set(encounterComp)
                    print("NPC \(encounterComp.data.idCardData.printedName) siap diinterogasi.")
                    
                case .entered, .dismissed:
                    // NPC sudah selesai berjalan masuk atau lari keluar
                    entity.removeFromParent()
                    print("NPC dihapus dari scene.")
                    
                case .interrogated:
                    // Tidak melakukan apa-apa, NPC sedang diam diinterogasi
                    break
                }
            }
        }
    }
}

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
        let query = EntityQuery(where: .has(MoveToTargetComponent.self) && .has(ActiveEncounterComponent.self))
        
        for entity in context.entities(matching: query, updatingSystemWhen: .rendering) {
            guard let moveComponent = entity.components[MoveToTargetComponent.self],
                  var encounterComp = entity.components[ActiveEncounterComponent.self] else { continue }
            
            let currentPos = entity.position
            let targetPos = moveComponent.targetPosition
            let direction = targetPos - currentPos
            let distance = length(direction)
            
            if distance > 0.1 {
                // Terus bergerak
                let normalizedDirection = direction / distance
                entity.position += normalizedDirection * moveComponent.speed * deltaTime
            } else {
                // Sudah sampai tujuan
                entity.components.remove(MoveToTargetComponent.self)
                
                switch encounterComp.state {
                case .walkingToPost:
                    // 🎬 NPC sampai di meja satpam
                    encounterComp.state = .interrogated
                    entity.components.set(encounterComp)
                    
                    // 🔄 HADAP 0 DERAJAT (Menghadap Pemain)
                    entity.orientation = simd_quatf(angle: 0, axis: SIMD3<Float>(0, 1, 0))
                    
                    // Stop jalan, mainkan idle
                    entity.stopAllAnimations()
                    if let idle = encounterComp.idleAnimation {
                        entity.playAnimation(idle.repeat(duration: .infinity), transitionDuration: 0.5)
                    }
                    
                    print("NPC \(encounterComp.data.idCardData.printedName) siap diinterogasi.")
                    
                case .entered, .dismissed:
                    entity.removeFromParent()
                    print("NPC dihapus dari scene.")
                    
                case .interrogated:
                    break
                }
            }
        }
    }
}

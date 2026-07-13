//
//  GateSystem.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 13/07/26.
//

import RealityKit
import simd

public struct GateSystem: System {
    // Query untuk mencari semua Entity yang punya GateComponent
    private static let query = EntityQuery(where: .has(GateComponent.self))
    
    public init(scene: RealityKit.Scene) {}
    
    public func update(context: SceneUpdateContext) {
        let deltaTime = Float(context.deltaTime)
        
        for entity in context.scene.performQuery(Self.query) {
            guard var gateComp = entity.components[GateComponent.self] else { continue }
            
            // Variabel untuk melacak apakah rotasi perlu diupdate frame ini
            var needsUpdate = false
            var targetRotation = entity.transform.rotation
            
            switch gateComp.state {
            case .opening:
                // Interpolasi halus (slerp) menuju openRotation
                targetRotation = simd_slerp(entity.transform.rotation, gateComp.openRotation, gateComp.animationSpeed * deltaTime)
                needsUpdate = true
                
                // Cek apakah sudah sangat dekat dengan target rotasi buka
                if simd_distance(targetRotation.vector, gateComp.openRotation.vector) < 0.001 {
                    targetRotation = gateComp.openRotation // Snap ke ujung
                    gateComp.state = .open
                }
                
            case .closing:
                // Interpolasi halus (slerp) menuju closedRotation
                targetRotation = simd_slerp(entity.transform.rotation, gateComp.closedRotation, gateComp.animationSpeed * deltaTime)
                needsUpdate = true
                
                // Cek apakah sudah sangat dekat dengan target rotasi tutup
                if simd_distance(targetRotation.vector, gateComp.closedRotation.vector) < 0.001 {
                    targetRotation = gateComp.closedRotation // Snap ke ujung
                    gateComp.state = .closed
                }
                
            case .open, .closed:
                // Tidak melakukan apa-apa jika sudah mentok di posisi state-nya
                break
            }
            
            if needsUpdate {
                // Terapkan rotasi baru ke entity
                entity.transform.rotation = targetRotation
                // Simpan kembali komponen yang state-nya mungkin berubah
                entity.components.set(gateComp)
            }
        }
    }
}

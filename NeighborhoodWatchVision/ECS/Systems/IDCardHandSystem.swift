//
//  IDCardHandSystem.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 15/07/26.
//

import RealityKit
import ARKit
import ILSHandTracking // Sesuaikan dengan module hand tracking milikmu

public class IDCardHandSystem: System {
    public static let query = EntityQuery(where: .has(IDCardHandComponent.self))
        
    required public init(scene: RealityKit.Scene) {}
    
    public func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            
            guard let component = entity.components[IDCardHandComponent.self] else { continue }
            
            // Ambil data tangan kiri atau kanan
            let handAnchor = (component.chirality == .left) ?
                HandTrackingService.shared.latestLeftHand :
                HandTrackingService.shared.latestRightHand
            
            // Jika tangan terdeteksi dan di-track
            guard let trackedHand = handAnchor, trackedHand.isTracked else {
                // Sembunyikan ID Card jika tangan tidak terlihat
                entity.isEnabled = false
                continue
            }
            
            // Tampilkan ID Card jika tangan terlihat
            entity.isEnabled = true
            
            // Ambil posisi tangan di dunia (World Space)
            let handWorldTransform = trackedHand.originFromAnchorTransform
            
            // Terapkan ke entitas ID Card (relativeTo: nil berarti World Space,
            // sehingga dia mengabaikan posisi Parent-nya yaitu si NPC)
            entity.setTransformMatrix(handWorldTransform, relativeTo: nil)
            
            // Catatan: Jika posisinya aneh (misal menusuk tangan), kamu bisa mengalikan
            // handWorldTransform dengan matrix offset rotasi/translasi di sini.
        }
    }
}

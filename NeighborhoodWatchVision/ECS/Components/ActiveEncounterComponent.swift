//
//  ActiveEncounterComponent.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 10/07/26.
//

import RealityKit

// Komponen untuk menyimpan data spesifik NPC dan state-nya saat ini
struct ActiveEncounterComponent: Component {
    var data: EncounterData
    var state: EncounterState = .walkingToPost
    
    enum EncounterState {
        case walkingToPost, interrogated, dismissed, entered
    }
}

// Komponen untuk target pergerakan
struct MoveToTargetComponent: Component {
     var targetPosition: SIMD3<Float>
     var speed: Float
}

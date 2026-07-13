//
//  ActiveEncounterComponent.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 10/07/26.
//

import RealityKit

struct ActiveEncounterComponent: Component {
    var data: EncounterData
    var state: EncounterState = .walkingToPost
    
    // Tambahkan 2 baris ini untuk menyimpan animasi
    var walkAnimation: AnimationResource?
    var idleAnimation: AnimationResource?
    
    enum EncounterState {
        case walkingToPost, interrogated, dismissed, entered
    }
}

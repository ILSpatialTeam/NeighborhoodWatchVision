//
//  IDCardHandComponent.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 15/07/26.
//

import ARKit
import RealityKit

struct IDCardHandComponent: Component {
    public let chirality: HandAnchor.Chirality
    
    public init(chirality: HandAnchor.Chirality = .right) {
        self.chirality = chirality
    }
}


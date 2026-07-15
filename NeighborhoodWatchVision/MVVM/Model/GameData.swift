//
//  GameData.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 08/07/26.
//

import Foundation

struct GameData: Codable {
    let villageMap: VillageMap
    let residents: [ResidentManifest]
    let encounters: [EncounterData]
}

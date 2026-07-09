//
//  VillageData.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 07/07/26.
//

import Foundation

struct HouseData: Codable, Identifiable {
    var id: String { houseID }
    let houseID: String
    let fullAddress: String
    let residentID: String?
    let residentName: String?
    let leftNeighborID: String?
    let rightNeighborID: String?
    let facingNeighborID: String?
    let hasParkedVehicle: Bool
}

struct VillageMap: Codable {
    let houses: [String: HouseData]
}

enum NeighborPosition: String, Codable {
    case left, right, facing
}

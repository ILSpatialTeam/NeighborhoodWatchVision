//
//  VillageData.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 07/07/26.
//

import Foundation

// MARK: - Root Root JSON Wrapper
struct GameData: Codable {
    let villageMap: VillageMap
    let residents: [ResidentManifest]
    let encounters: [EncounterData]
}

// MARK: - Map & Spatial Data
struct HouseData: Codable, Identifiable {
    var id: String { houseID }
    let houseID: String
    let fullAddress: String
    let residentID: String?
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

// MARK: - Resident Manifest
struct ResidentManifest: Codable, Identifiable {
    var id: String { residentID }
    let residentID: String
    let trueName: String
    let trueAddress: String
    let dateOfBirth: String? // Ditambahkan
    let occupation: String
    let relation: String
    let visualTraits: [String]
    let personality: String
    let secretLore: String
}

// MARK: - Encounters & Anomalies
struct EncounterData: Codable, Identifiable {
    var id: String { encounterID }
    let encounterID: String
    let scenarioName: String
    let spawnVisuals: [String]
    let idCardData: IDCardData
    let llmPromptContext: LLMPromptContext
    let idImageURL: String // Ditambahkan
}

struct IDCardData: Codable {
    let printedName: String
    let printedAddress: String
    let dateOfBirth: String? // Ditambahkan
    let printedIDNumber: String
    let expirationDate: String
}

enum RoleType: String, Codable {
    case resident
    case anomaly
}

struct LLMPromptContext: Codable {
    let roleType: RoleType
    let characterName: String
    let believedAddress: String
    let believedOccupation: String
    let spatialContext: String
    let behavioralInstruction: String
}

//
//  ResidentData.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 07/07/26.
//

// MARK: - Resident Manifest (Buku Catatan Penjaga / Source of Truth)
//struct ResidentManifest: Codable {
//    let residentID: String
//    let trueName: String
//    let trueAddress: String
//    let occupation: String
//    let relation: String
//    let visualTraits: [String]   // Misal: ["Kacamata", "Tahi lalat di pipi kiri"]
//    let personality: String      // Misal: "Pemarah dan selalu terburu-buru"
//    let secretLore: String       // Misal: "Fobia terhadap anjing"
//}
//
//// MARK: - Physical ID Card (Objek 3D yang bisa dipegang pemain)
//struct IDCardData: Codable {
//    let printedName: String
//    let printedAddress: String
//    let printedIDNumber: String
//    let expirationDate: String
////    let hasValidHologram: Bool   // Jika false, shader hologram di kartu tidak menyala
////    let photoMatchesEntity: Bool // Jika false, tekstur foto di kartu beda dengan model 3D di depan pemain
//}
//
//// MARK: - LLM State (Otak Karakter)
//enum RoleType: String, Codable {
//    case resident
//    case anomaly
//}
//
//struct LLMPromptContext: Codable {
//    let roleType: RoleType
//    let characterName: String
//    let believedAddress: String
//    let believedOccupation: String
//    let spatialContext: String
//    let behavioralInstruction: String
//}

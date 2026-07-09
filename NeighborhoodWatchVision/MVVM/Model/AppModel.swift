//
//  AppModel.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 06/07/26.
//

import SwiftUI

/// Maintains app-wide state
@MainActor
@Observable
class AppModel {
    let immersiveSpaceID = "ImmersiveSpace"
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    
    var immersiveSpaceState = ImmersiveSpaceState.closed
    
    var gameData: GameData? = nil
        
    
    func loadGameData() {
        guard gameData == nil else { return }
        guard let url = Bundle.main.url(forResource: "Village", withExtension: "json") else {
            print("Error: File Village.json tidak ditemukan di dalam project.")
            return
        }
            
        do {
            let data = try Data(contentsOf: url)
            let decodedData = try JSONDecoder().decode(GameData.self, from: data)
            self.gameData = decodedData
        } catch {
            print("Gagal melakukan decode file Village.json: \(error.localizedDescription)")
            print("Detail Error: \(error)")
        }
    }
}

//
//  ResultView.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 14/07/26.
//

import SwiftUI

struct ResultView: View {
    @Environment(AppModel.self) var model
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.dismissWindow) var dismissWindow
    let isWin: Bool
    
    var body: some View {
        VStack(spacing: 40) {
            Text(isWin ? "MISSION ACCOMPLISHED" : "GAME OVER")
                .font(.system(size: 60, weight: .black))
                .foregroundColor(isWin ? .green : .red)
            
            Text(isWin ? "You successfully kept the neighborhood safe." : "An anomaly managed to infiltrate.")
                .font(.title)
            
            HStack(spacing: 30) {
                FrameButton(title: "Retry") {
                    Task {
                        model.currentFlow = .playing
                        dismissWindow()
                    }
                }
                
                FrameButton(title: "Main Menu") {
                    model.currentFlow = .start
                    Task { await dismissImmersiveSpace() }
                }
            }
        }
        .padding(60)
    }
}

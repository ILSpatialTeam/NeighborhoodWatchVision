//
//  ContentView.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 10/07/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(AppModel.self) var model
    
    var body: some View {
//        AIPlaygroundView()
        Group {
            switch model.currentFlow {
            case .start:
                StartView()
            case .story:
                StoryView()
            case .playing:
                AIPrepView()
                    .environment(model)
            case .result(let isWin):
                ResultView(isWin: isWin)
            }
        }
        .onAppear {
            model.loadGameData()
        }
        .animation(.default, value: model.currentFlow)
    }
}

struct FrameButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title2)
                .bold()
                .foregroundColor(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 20)
                .background(
                    Image("button_frame")
                        .resizable()
                )
        }
        .buttonStyle(.plain)
    }
}

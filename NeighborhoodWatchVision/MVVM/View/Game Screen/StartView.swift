//
//  StartView.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 14/07/26.
//

import SwiftUI

struct StartView: View {
    @Environment(AppModel.self) var model
    
    var body: some View {
        Image("game_title")
            .resizable()
            .scaledToFit()
            .ornament(attachmentAnchor: .scene(.bottom), contentAlignment: .top) {
                FrameButton(title: "Start the Game") {
                    model.currentFlow = .story
                }
                .padding(.top, 20)
            }
    }
}

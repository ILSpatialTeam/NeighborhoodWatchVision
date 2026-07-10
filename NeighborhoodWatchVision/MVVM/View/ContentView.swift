//
//  ContentView.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 10/07/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissWindow) var dismissWindow
    
    @Environment(AppModel.self) var model
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Gerbang Perumahan")
                .font(.extraLargeTitle)
                .bold()
            
            ToggleImmersiveSpaceButton()
        }
        .onAppear {
            model.loadGameData()
        }
    }
}

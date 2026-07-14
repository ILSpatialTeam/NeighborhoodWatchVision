//
//  HUDView.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 11/07/26.
//

import SwiftUI

struct HUDView: View {
    @Environment(SpeechPlaygroundViewModel.self) var speech
    
//    var gameState: GameState
    var timeString: String = "00.00"
    
    var playerText: String = "Halo, permisi pak..."
    var subtitleText: String = "Malam pak, nyari siapa ya?"
  
    var isRecording: Bool = false
    var onToggleMic: () -> Void = {}
    
    var body: some View {
        VStack {
            HStack {
                
                Spacer()
                
                // Timer
                Text(timeString)
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
            }
            
            Spacer()
            xw
            VStack(spacing: 8) {
                Button(action: {
                    speech.toggleRecording()
                }) {
                    HStack {
                        Image(systemName: speech.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        Text(speech.isRecording ? "Listening..." : "Mic Off")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(isRecording ? .red : .white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(20)
                }
                .padding(.leading, 24)
                .padding(.vertical, 12)
                
//                if !playerText.isEmpty {
                Text(speech.recordedText.isEmpty ? "..." : speech.recordedText)
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
//                }
//                Text(viewModel.recordedText.isEmpty ? "..." : viewModel.recordedText)
//                    .font(.body)
//                    .padding()
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .background(Color.gray.opacity(0.1))
//                    .cornerRadius(8)
//            }
//                if !subtitleText.isEmpty {
                    Text(subtitleText)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
//                }
            }
            .padding(.bottom, 30)
        }
        .frame(width: 1000, height: 600)
    }
}

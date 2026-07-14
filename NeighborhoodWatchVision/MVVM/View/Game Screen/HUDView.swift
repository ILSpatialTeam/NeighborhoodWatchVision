//
//  HUDView.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 11/07/26.
//

import SwiftUI

struct HUDView: View {
    @Environment(AppModel.self) var appModel
    @State private var speech = SpeechPlaygroundViewModel()
    
    var timeString: String = "00.00"
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text(timeString)
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
            }
            
            Spacer()
            
            VStack(spacing: 8) {
                Button(action: {
                    if speech.isRecording {
                        let textToSend = speech.recordedText.trimmingCharacters(in: .whitespacesAndNewlines)
                        speech.toggleRecording()
                        if !textToSend.isEmpty {
                            if let currentEncounter = appModel.gameViewModel.activeEncounter {
                                Task {
                                    await appModel.encounterViewModel.interactWithNPC(playerSpeech: textToSend, encounter: currentEncounter)
                                }
                            }
                            Task {
                                try? await Task.sleep(nanoseconds: 3_000_000_000)
                                if !speech.isRecording {
                                    speech.recordedText = ""
                                }
                            }
                        }
                    } else {
                        speech.recordedText = ""
                        speech.toggleRecording()
                    }
                }) {
                    HStack {
                        Image(systemName: speech.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        Text(speech.isRecording ? "Listening..." : "Mic Off")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(speech.isRecording ? .red : .white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(20)
                }
                .padding(.leading, 24)
                .padding(.vertical, 12)
                .disabled(!appModel.encounterViewModel.isModelLoaded || appModel.encounterViewModel.isNPCThinking)
                
                Text(speech.recordedText.isEmpty ? "..." : speech.recordedText)
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                if appModel.encounterViewModel.isNPCThinking {
                    Text("Berpikir...")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.yellow)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                } else {
                    let npcText = appModel.encounterViewModel.npcDialogue
                    Text(npcText.isEmpty ? "..." : npcText)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
            }
            .padding(.bottom, 30)
        }
        .frame(width: 1000, height: 600)
        .onChange(of: appModel.gameViewModel.currentEncounterIndex) { _, _ in
            appModel.encounterViewModel.resetDialogue()
        }
    }
}

//
//  AIPlayGroundView.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 14/07/26.
//

import SwiftUI

public struct AIPlaygroundView: View {
    @State private var viewModel = SpeechPlaygroundViewModel()
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("🗣️ Speech Playground")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)
                
                // MARK: - PANEL 1: Uji Mikrofon (Speech-to-Text)
                VStack(alignment: .leading, spacing: 15) {
                    Text("1. Speech-to-Text (Mic)")
                        .font(.title2).bold()
                    
                    Button(action: {
                        viewModel.toggleRecording()
                    }) {
                        HStack {
                            Image(systemName: viewModel.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                            Text(viewModel.isRecording ? "Berhenti Merekam" : "Mulai Merekam")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(viewModel.isRecording ? .red : .blue)
                    
                    VStack(alignment: .leading) {
                        Text("Hasil Transkripsi:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(viewModel.recordedText.isEmpty ? "..." : viewModel.recordedText)
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.05))
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.blue.opacity(0.3), lineWidth: 1))
                
                // MARK: - PANEL 2: Uji Speaker (Text-to-Speech)
                VStack(alignment: .leading, spacing: 15) {
                    Text("2. Text-to-Speech (Speaker)")
                        .font(.title2).bold()
                    
                    TextField("Ketik teks untuk disuarakan...", text: $viewModel.textToSpeak)
                        .textFieldStyle(.roundedBorder)
                        .padding(.vertical, 5)
                    
                    HStack {
                        Button(action: {
                            viewModel.speak()
                        }) {
                            Label("Bacakan Teks", systemImage: "speaker.wave.3.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        
                        Button(action: {
                            viewModel.speechManager.stopSpeaking()
                        }) {
                            Image(systemName: "speaker.slash.fill")
                                .padding(.horizontal)
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                    }
                }
                .padding()
                .background(Color.green.opacity(0.05))
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.green.opacity(0.3), lineWidth: 1))
                
                // MARK: - PANEL 3: Log Konsol
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("3. System Logs")
                            .font(.title2).bold()
                        Spacer()
                        Button("Clear", action: { viewModel.clearLogs() })
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                            .tint(.red)
                    }
                    
                    ScrollView {
                        // Menggunakan array logs dari ConsoleLogger di dalam SpeechManager
                        Text(viewModel.speechManager.logger.logs.joined(separator: "\n"))
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.green)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(height: 150)
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(8)
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
            }
            .padding()
        }
    }
}

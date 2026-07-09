//
//  IntrogationView.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 08/07/26.
//

import SwiftUI

public struct InterrogationView: View {
    // Asumsi: AppCoordinator sekarang menyimpan instance EncounterViewModel
    @Environment(AppCoordinator.self) private var coordinator
    @State private var speechRecognizer = SpeechRecognizer()
    
    // Opsional: Untuk membuka/menutup sesi Immersive Space
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @State private var isImmersiveSpaceOpen = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 20) {
            // Header
            Text("Pos Penjagaan: Interogasi")
                .font(.extraLargeTitle)
            
            // STATE 1: MODEL SEDANG LOADING
            if coordinator.encounterVM.isLoading {
                VStack(spacing: 10) {
                    ProgressView(coordinator.encounterVM.loadingStatus, value: coordinator.encounterVM.downloadProgress, total: 1.0)
                        .progressViewStyle(.linear)
                    Text("\(Int(coordinator.encounterVM.downloadProgress * 100))%")
                        .font(.caption)
                }
                .padding()
            }
            // STATE 2: MODEL BELUM DILOAD
            else if !coordinator.encounterVM.isModelLoaded {
                Button("Nyalakan Sistem AI Pos") {
                    Task {
                        await coordinator.encounterVM.loadModel()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            // STATE 3: MODEL SIAP BERAKSI
            else {
                // UI Karakter Aktif
                GroupBox {
                    if let activeChar = coordinator.encounterVM.activeEncounter {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text(activeChar.scenarioName)
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(activeChar.llmPromptContext.roleType == .anomaly ? .red : .primary)
                                Spacer()
                                Button("Next Character") {
                                    coordinator.encounterVM.startNextEncounter()
                                }
                                .buttonStyle(.bordered)
                            }
                            
                            Divider()
                            
                            // Streaming Teks dari AI
                            ScrollView {
                                Text(coordinator.encounterVM.npcDialogue.isEmpty ? "..." : coordinator.encounterVM.npcDialogue)
                                    .font(.title3)
                                    .italic()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .frame(height: 100)
                            
                            if coordinator.encounterVM.isNPCThinking {
                                ProgressView("Karakter sedang berpikir...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                    } else {
                        VStack(spacing: 15) {
                            Text("Tidak ada orang di depan pos.")
                                .foregroundColor(.secondary)
                            Button("Mulai Shift / Panggil Antrean") {
                                coordinator.encounterVM.startNextEncounter()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                    }
                }
                .frame(maxWidth: 500)
                
                // UI Input Suara (Player)
                VStack(spacing: 10) {
                    Text(speechRecognizer.isListening ? "Listening... Katakan 'Halo Penjaga <pertanyaan>'" : "Mic mati.")
                        .foregroundColor(speechRecognizer.isListening ? .green : .red)
                    
                    Button(speechRecognizer.isListening ? "Stop Mic" : "Start Mic") {
                        if speechRecognizer.isListening {
                            speechRecognizer.stopListening()
                        } else {
                            speechRecognizer.startListening()
                        }
                    }
                    .buttonStyle(.bordered)
                    
                    Text("Terdengar: \(speechRecognizer.transcript)")
                        .italic()
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 10)
            }
            
            // System Log (Disembunyikan sedikit agar tidak mendominasi layar)
            DisclosureGroup("System Logs") {
                ScrollView {
                    Text(coordinator.encounterVM.logText)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(height: 120)
            }
            .frame(maxWidth: 400)
            .padding(.top, 10)
        }
        .padding(40)
        .glassBackgroundEffect()
        .onAppear {
            // Sambungkan event suara ke fungsi interogasi
            speechRecognizer.onCommandDetected = { command in
                Task {
                    await coordinator.encounterVM.interactWithNPC(playerSpeech: command)
                }
            }
        }
    }
}

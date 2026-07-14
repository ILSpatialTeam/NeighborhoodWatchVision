//
//  AIPrepView.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 14/07/26.
//

import SwiftUI

struct AIPrepView: View {
    @Environment(AppModel.self) var model
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissWindow) var dismissWindow
    
    var body: some View {
        VStack(spacing: 30) {
            
            VStack(spacing: 12) {
                Image(systemName: "shield.righthalf.filled")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)
                    .symbolEffect(.pulse)
                
                Text("Pos Penjagaan")
                    .font(.extraLargeTitle)
                    .fontWeight(.bold)
                
                Text("Sistem Interogasi AI")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 10)
            
            Group {
                if model.encounterViewModel.isLoading {
                    VStack(spacing: 16) {
                        Text("Menginisialisasi Jaringan AI...")
                            .font(.headline)
                        
                        ProgressView(value: model.encounterViewModel.downloadProgress, total: 1.0)
                            .progressViewStyle(.linear)
                            .tint(.blue)
                        
                        HStack {
                            Text(model.encounterViewModel.loadingStatus.isEmpty ? "Menyiapkan data..." : model.encounterViewModel.loadingStatus)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Text("\(Int(model.encounterViewModel.downloadProgress * 100))%")
                                .font(.caption.bold())
                                .foregroundStyle(.primary)
                        }
                    }
                    .padding(24)
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .frame(maxWidth: 400)
                    
                } else if !model.encounterViewModel.isModelLoaded {
                    VStack(spacing: 16) {
                        Text("Sistem AI saat ini dalam keadaan mati. Nyalakan sistem untuk memulai shift penjagaan Anda.")
                            .font(.callout)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 20)
                        
                        Button(action: {
                            Task {
                                await model.encounterViewModel.loadModel()
                            }
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: "power")
                                Text("Nyalakan Sistem AI")
                                    .fontWeight(.semibold)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .controlSize(.large)
                    }
                    .frame(maxWidth: 400)
                    
                } else {
                    VStack(spacing: 24) {
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(.green)
                                .font(.title2)
                            Text("Sistem AI Aktif & Siap")
                                .font(.headline)
                                .foregroundStyle(.green)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(Color.green.opacity(0.15))
                        .clipShape(Capsule())
                        
                        FrameButton(title: "Mulai Shift (Masuk Pos)") {
                            Task {
                                model.currentFlow = .playing
                                await openImmersiveSpace(id: model.immersiveSpaceID)
                                dismissWindow()
                            }
                        }
                    }
                }
            }
            .animation(.easeInOut(duration: 0.4), value: model.encounterViewModel.isLoading)
            .animation(.easeInOut(duration: 0.4), value: model.encounterViewModel.isModelLoaded)
        }
        .padding(50)
        .frame(width: 600, height: 500)
    }
}

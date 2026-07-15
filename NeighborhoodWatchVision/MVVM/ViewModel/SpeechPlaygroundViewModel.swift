//
//  SpeechPlaygroundViewModel.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 14/07/26.
//

import SwiftUI
import Observation

@MainActor
@Observable
public final class SpeechPlaygroundViewModel {
    public var isRecording = false
    public var recordedText = ""
    public var textToSpeak = "Halo, selamat datang di pos satpam."
    
    public let speechManager = SpeechManager.shared
    
    public init() {}
    
    public func toggleRecording() {
        if isRecording {
            isRecording = false
            speechManager.stopListening()
        } else {
            isRecording = true
            recordedText = ""
            speechManager.stopSpeaking()
            speechManager.startListening { [weak self] text in
                Task { @MainActor in
                    guard let self else { return }
                    self.recordedText = text
                }
            }
        }
    }
    
    public func speak() {
        guard !textToSpeak.isEmpty else { return }
        speechManager.speak(textToSpeak)
    }
    
    public func clearLogs() {
        speechManager.clearLogs()
    }
}

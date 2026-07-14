//
//  AppleSpeechTranscriber.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 14/07/26.
//

import Foundation
import Speech
import AVFoundation

public final class AppleSpeechTranscriber: NSObject, SpeechTranscriber, SFSpeechRecognizerDelegate, @unchecked Sendable {

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    private var onSpeechDetected: (@Sendable (String) -> Void)?
    
    public override init() {
        super.init()
        speechRecognizer?.delegate = self
    }
    
    public func startTranscribing(onSpeechDetected: @escaping @Sendable (String) -> Void) {
        self.onSpeechDetected = onSpeechDetected
        
        guard let recognizer = speechRecognizer else {
            print("Error: Speech recognizer tidak terinisialisasi")
            return
        }
        guard recognizer.isAvailable else {
            print("Error: Speech recognizer sedang tidak tersedia")
            return
        }
        
        let status = SFSpeechRecognizer.authorizationStatus()
        
        switch status {
        case .authorized:
            do {
                try self.startRecording()
            } catch {
                print("Mic Error: \(error.localizedDescription)")
            }
        case .notDetermined:
            SFSpeechRecognizer.requestAuthorization { [weak self] newStatus in
                if newStatus == .authorized {
                    DispatchQueue.main.async {
                        try? self?.startRecording()
                    }
                } else {
                    print("Auth Denied: \(newStatus.rawValue)")
                }
            }
        default:
            print("Speech recognition not authorized: \(status.rawValue)")
        }
    }
    
    public func stopTranscribing() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        recognitionRequest?.endAudio()
        onSpeechDetected = nil
    }
    
    private func startRecording() throws {
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        // Pastikan tidak ada tap lama yang tersisa
        audioEngine.inputNode.removeTap(onBus: 0)
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else { return }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self else { return }
            
            let transcription = result?.bestTranscription.formattedString
            let hasError = (error != nil)
            let isFinal = result?.isFinal ?? false
            
            DispatchQueue.main.async {
                if let transcription = transcription {
                    self.onSpeechDetected?(transcription)
                }
                
                if hasError || isFinal {
                    self.audioEngine.stop()
                    self.audioEngine.inputNode.removeTap(onBus: 0)
                    self.recognitionRequest = nil
                    self.recognitionTask = nil
                }
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }
}

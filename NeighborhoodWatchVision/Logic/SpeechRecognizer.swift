//
//  SpeechRecognizer.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo
//

import Speech
import AVFoundation

@Observable @MainActor
public class SpeechRecognizer: NSObject, SFSpeechRecognizerDelegate {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var commandTimer: Timer?
    
    public var transcript: String = ""
    public var isListening: Bool = false
    public var onCommandDetected: ((String) -> Void)?
    
    public override init() {
        super.init()
        speechRecognizer?.delegate = self
    }
    
    public func startListening() {
        guard let recognizer = speechRecognizer else {
            self.transcript = "Error: Locale id-ID not supported!"
            return
        }
        guard recognizer.isAvailable else {
            self.transcript = "Error: Speech recognizer is not available right now."
            return
        }
        
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                if status == .authorized {
                    do {
                        try self.startRecording()
                        self.isListening = true
                        self.transcript = "Listening..."
                    } catch {
                        self.transcript = "Mic Error: \(error.localizedDescription)"
                    }
                } else {
                    self.transcript = "Auth Denied: \(status.rawValue)"
                }
            }
        }
    }
    
    public func stopListening() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        recognitionRequest?.endAudio()
        isListening = false
    }
    
    private func startRecording() throws {
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        // Ensure no previous tap is left behind
        audioEngine.inputNode.removeTap(onBus: 0)
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else { return }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            if let result = result {
                let text = result.bestTranscription.formattedString
                DispatchQueue.main.async {
                    self.transcript = text
                }
                
                let lowercased = text.lowercased()
                if lowercased.contains("hi brother") || lowercased.contains("hai brother") {
                    let command = lowercased.components(separatedBy: "brother").last?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    if !command.isEmpty {
                        DispatchQueue.main.async {
                            // Wait for 1.5 seconds of silence before processing
                            self.commandTimer?.invalidate()
                            self.commandTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
                                self.onCommandDetected?(command)
                                self.stopListening()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    self.startListening()
                                }
                            }
                        }
                    }
                }
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                if let error = error {
                    DispatchQueue.main.async {
                        self.transcript = "Rec Error: \(error.localizedDescription)"
                    }
                }
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
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

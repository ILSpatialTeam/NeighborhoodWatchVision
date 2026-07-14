//
//  SpeechManager.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 14/07/26.
//

import Foundation
import Observation

@MainActor
@Observable
public final class SpeechManager {
    
    // Singleton instance (asumsikan AppleSpeechTranscriber & AppleSpeechSynthesizer sudah kamu buat)
    public static let shared = SpeechManager(
        transcriber: AppleSpeechTranscriber(),
        synthesizer: AppleSpeechSynthesizer(),
        logger: ConsoleLogger()
    )
    
    // Protocols
    private let transcriber: SpeechTranscriber
    private let synthesizer: SpeechSynthesizer
    public let logger: GameLogger
    
    // Dependency Injection
    public init(
        transcriber: SpeechTranscriber,
        synthesizer: SpeechSynthesizer,
        logger: GameLogger
    ) {
        self.transcriber = transcriber
        self.synthesizer = synthesizer
        self.logger = logger
    }
    
    // MARK: - Speech-to-Text (Mic / Transcriber)
    
    public func startListening(onTranscriptionUpdate: @escaping @Sendable (String) -> Void) {
        logger.addLog("Listening started. Recording mic buffer...")
        
        transcriber.startTranscribing { [weak self] text in
            Task { @MainActor in
                guard let self else { return }
                // Opsional: Buka komentar di bawah jika ingin melog setiap kata (bisa spammy)
                // self.logger.addLog("Transcript updated: \"\(text)\"")
                onTranscriptionUpdate(text)
            }
        }
    }
    
    public func stopListening() {
        logger.addLog("Listening stopped.")
        transcriber.stopTranscribing()
    }
    
    // MARK: - Text-to-Speech (Speaker / Synthesizer)
    
    public func speak(_ text: String) {
        guard !text.isEmpty else { return }
        logger.addLog("Speaking: '\(text)'")
        synthesizer.startSpeaking(text)
    }
    
    public func stopSpeaking() {
        logger.addLog("Speaking stopped.")
        synthesizer.stopSpeaking()
    }
    
    // MARK: - Logging
    
    public func clearLogs() {
        logger.clearLogs()
    }
}


public protocol GameLogger: AnyObject {
    var logs: [String] { get }
    func addLog(_ message: String)
    func clearLogs()
}

// MARK: - Logger Implementation

@Observable
public final class ConsoleLogger: GameLogger {
    public private(set) var logs: [String] = []
    
    public init() {
        addLog("System Logger Initialized.")
    }
    
    public func addLog(_ message: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let time = formatter.string(from: Date())
        logs.append("[\(time)] \(message)")
    }
    
    public func clearLogs() {
        logs = ["[\(Date())] Logs cleared."]
    }
}

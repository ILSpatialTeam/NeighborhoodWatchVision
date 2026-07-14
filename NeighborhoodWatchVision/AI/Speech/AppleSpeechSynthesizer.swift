//
//  AppleSpeechSynthesizer.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 14/07/26.
//

import Foundation
import AVFoundation

public final class AppleSpeechSynthesizer: SpeechSynthesizer {
    public let synthesizer = AVSpeechSynthesizer()
    
    public init() {}
    
    public func startSpeaking(_ text: String) {
        stopSpeaking()
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.pitchMultiplier = 0.8
        utterance.rate = 0.5
        
        synthesizer.speak(utterance)
    }
    
    public func stopSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .word)
        }
    }
}

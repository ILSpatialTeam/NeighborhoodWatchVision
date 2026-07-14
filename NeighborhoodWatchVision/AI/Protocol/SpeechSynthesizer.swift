//
//  SpeechSynthesizer.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 14/07/26.
//

import Foundation

public protocol SpeechSynthesizer: AnyObject {
    
    func startSpeaking(_ text: String)
    
    func stopSpeaking()
}

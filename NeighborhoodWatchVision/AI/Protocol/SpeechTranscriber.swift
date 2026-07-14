//
//  SpeechTranscriber.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 14/07/26.
//

import Foundation

public protocol SpeechTranscriber: AnyObject {
    //start record and transcript real time
    func startTranscribing(onSpeechDetected: @escaping @Sendable (String) -> Void)
    //stop record
    func stopTranscribing()
}

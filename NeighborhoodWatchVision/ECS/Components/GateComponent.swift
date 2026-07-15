//
//  GateComponent.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 13/07/26.
//

import RealityKit
import simd

public struct GateComponent: Component {
    public enum GateState {
        case closed
        case opening
        case open
        case closing
    }
    
    public var state: GateState = .closed
    
    // Konfigurasi Animasi
    public var animationSpeed: Float = 2.0 // Seberapa cepat pintu membuka (radian per detik)
    
    // Rotasi asli (tertutup) dan rotasi saat terbuka
    public var closedRotation: simd_quatf
    public var openRotation: simd_quatf
    
    /// Inisialisasi awal. Secara default, pintu dianggap berada di posisi tertutup.
    /// - Parameters:
    ///   - closedRotation: Rotasi pintu saat ini (tertutup).
    ///   - openAngle: Seberapa besar pintu membuka (dalam radian). Misal: .pi / 2 (90 derajat).
    ///   - axis: Sumbu putaran (biasanya [0, 1, 0] untuk sumbu Y).
    public init(closedRotation: simd_quatf, openAngle: Float, axis: SIMD3<Float> = [0, 1, 0]) {
        self.closedRotation = closedRotation
        // Hitung rotasi target berdasarkan sudut yang diberikan
        self.openRotation = closedRotation * simd_quatf(angle: openAngle, axis: axis)
    }
}

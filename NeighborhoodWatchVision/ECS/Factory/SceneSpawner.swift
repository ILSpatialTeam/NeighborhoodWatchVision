//
//  SceneSpawner.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 11/07/26.
//

import RealityKit
import RealityKitContent

public struct SceneSpawner {
    @MainActor
    public static func spawnWorld(name sceneName: String = "Scenes/EnviScene") async -> Entity? {
        do {
            let scene = try await Entity(named: sceneName, in: realityKitContentBundle)
            let angle = Float.pi / 2
            scene.orientation = simd_quatf(angle: angle, axis: SIMD3<Float>(0, 1, 0))
            scene.position = SIMD3<Float>(0, 0, 0)
            
            print("[WorldSpawner] Sukses memuat dunia: \(sceneName)")
            
            if let redButton = scene.findEntity(named: "Button_Red"){
                print("Button merah ada! Setup sebagai Alarm.")
                redButton.name = "AlarmButton"
                redButton.components.set(InputTargetComponent())
                redButton.generateCollisionShapes(recursive: true)
                redButton.components.set(HoverEffectComponent())
            }
            
            if let greenButton = scene.findEntity(named: "Button_Green"){
                print("Button hijau ada! Setup sebagai Gate.")
                greenButton.name = "GateButton"
                greenButton.components.set(InputTargetComponent())
                greenButton.generateCollisionShapes(recursive: true)
                greenButton.components.set(HoverEffectComponent())
            }
            
            if let rightGate = scene.findEntity(named: "Right_Gate"){
                print("Right gate ada!")
            }
            
            if let leftGate = scene.findEntity(named: "Left_Gate"){
                print("Left gate ada!")
            }
            
            return scene
        } catch {
            print("[WorldSpawner] Gagal memuat scene '\(sceneName)': \(error)")
            return nil
        }
    }
}

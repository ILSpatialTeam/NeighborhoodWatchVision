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
            print("[WorldSpawner] Sukses memuat dunia: \(sceneName)")
            
            if let redButton = scene.findEntity(named: "Button_Red"){
//                print("Button merah ada! Setup sebagai Alarm.")
                redButton.name = "AlarmButton"
                redButton.components.set(InputTargetComponent())
                redButton.generateCollisionShapes(recursive: true)
                redButton.components.set(HoverEffectComponent())
            }
            
            if let greenButton = scene.findEntity(named: "Button_Green"){
//                print("Button hijau ada! Setup sebagai Gate.")
                greenButton.name = "GateButton"
                greenButton.components.set(InputTargetComponent())
                greenButton.generateCollisionShapes(recursive: true)
                greenButton.components.set(HoverEffectComponent())
            }
            
            // Di dalam SceneSpawner.swift

            if let rightGate = scene.findEntity(named: "Right_Gate") {
                // Right gate rotasi -90 derajat (.pi / 2) pada sumbu Y
                rightGate.components.set(GateComponent(
                    closedRotation: rightGate.transform.rotation,
                    openAngle: -.pi / 2
                ))
            }

            if let leftGate = scene.findEntity(named: "Left_Gate") {
                // Left gate rotasi 90 derajat (.pi / 2) pada sumbu Y
                leftGate.components.set(GateComponent(
                    closedRotation: leftGate.transform.rotation,
                    openAngle: .pi / 2
                ))
            }
            
            return scene
        } catch {
            print("[WorldSpawner] Gagal memuat scene '\(sceneName)': \(error)")
            return nil
        }
    }
}

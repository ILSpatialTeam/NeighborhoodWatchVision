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
    public static func spawnWorld(name sceneName: String = "Scenes/EnviScene 1") async -> Entity? {
        do {
            let scene = try await Entity(named: sceneName, in: realityKitContentBundle)
            print("[WorldSpawner] Sukses memuat dunia: \(sceneName)")
            
            if let redButton = scene.findEntity(named: "Button_Red"){
                redButton.name = "AlarmButton"
                redButton.components.set(InputTargetComponent())
                redButton.generateCollisionShapes(recursive: true)
                redButton.components.set(HoverEffectComponent())
            }
            
            if let greenButton = scene.findEntity(named: "Button_Green"){
                greenButton.name = "GateButton"
                greenButton.components.set(InputTargetComponent())
                greenButton.generateCollisionShapes(recursive: true)
                greenButton.components.set(HoverEffectComponent())
            }
            
            if let rightGate = scene.findEntity(named: "Right_Gate") {
                rightGate.components.set(GateComponent(
                    closedRotation: rightGate.transform.rotation,
                    openAngle: -.pi / 2
                ))
            }

            if let leftGate = scene.findEntity(named: "Left_Gate") {
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

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
            scene.position = SIMD3<Float>(0, 0, 0)
            
            print("[MedievalSceneSpawner] Sukses memuat dunia: \(sceneName)")
            
            if let redButton = scene.findEntity(named: "Button_Red"){
                print("Button merah ada!")
            }
            
            if let greenButton = scene.findEntity(named: "Button_Green"){
                print("Button hijau ada!")
            }
            
            if let rightGate = scene.findEntity(named: "Right_Gate"){
                print("Right gate ada!")
            }
            
            if let leftGate = scene.findEntity(named: "Left_Gate"){
                print("Left gate ada!")
            }
//
//            if let tower = rootWorld.findEntity(named: "Tower") {
//                print("[Tower] Local Position: \(tower.position)")
//                print("[Tower] World Position: \(tower.position(relativeTo: nil))")
//                var towerData = TowerComponent()
//                towerData.hp = 100
//                tower.components.set(towerData)
//                rootWorld.addChild(tower)
//            }
//            
//            if let portalEnemy = rootWorld.findEntity(named: "BlackHole") {
//                print("[portalEnemy] Local Position: \(portalEnemy.position)")
//                print("[portalEnemy] World Position: \(portalEnemy.position(relativeTo: nil))")
//                var portalData = PortalComponent()
//                if let enemy = await spawnEnemyPortal() {
//                    portalData.enemy = enemy
//                }
//                portalEnemy.components.set(portalData)
//                rootWorld.addChild(portalEnemy)
//            }
            return scene
        } catch {
            print("[MedievalSceneSpawner] Gagal memuat scene '\(sceneName)': \(error)")
            return nil
        }
    }
}

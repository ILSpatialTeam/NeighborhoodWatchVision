//
//  ImmersiveView.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 06/07/26.
//

import SwiftUI
import RealityKit
import RealityKitContent
import Combine
import ILSHandTracking

struct ImmersiveView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        RealityView { content, attachments in
            ILFeatureHandTrackingSetup.registerSystems()
            ActiveEncounterComponent.registerComponent()
            GateComponent.registerComponent()
            GateSystem.registerSystem()
            IDCardHandComponent.registerComponent()
            IDCardHandSystem.registerSystem()
            
            content.add(appModel.gameViewModel.encounterRoot)
            
            if let encounters = appModel.gameData?.encounters, !encounters.isEmpty {
                appModel.gameViewModel.startGame(with: encounters)
            }
            
            if let world = await SceneSpawner.spawnWorld() {
                appModel.gameViewModel.worldRoot = world
                content.add(world)
            }
            
            let headAnchor = AnchorEntity(.head)
            content.add(headAnchor)
            
            if let hudEntity = attachments.entity(for: "GameHUD") {
                hudEntity.position = SIMD3<Float>(0, 0, -0.8)
                headAnchor.addChild(hudEntity)
            }
            
        } update: { content, attachments in
            
        } attachments: {
            Attachment(id: "GameHUD") {
                HUDView()
                    .environment(appModel)
            }
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    guard case .playing = appModel.gameViewModel.gameState else { return }
                    appModel.gameViewModel.handleButtonPress(entityName: value.entity.name)
                }
        )
        .onChange(of: appModel.gameViewModel.gameState) { oldValue, newValue in
            switch newValue {
            case .won:
                print("Game Dimenangkan!")
                appModel.currentFlow = .result(isWin: true)
                openWindow(id: appModel.windowID)
                
            case .lost(let reason):
                print("Game Over: \(reason)")
                appModel.currentFlow = .result(isWin: false)
                openWindow(id: appModel.windowID)
                
            case .playing:
                break
            }
        }
        .onChange(of: appModel.currentFlow) { oldValue, newValue in
            if newValue == .playing && (appModel.gameViewModel.gameState != .playing) {
                appModel.gameViewModel.restartGame()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("RealityKit.NotificationTrigger"))) { notification in
            guard
                let userInfo = notification.userInfo,
                let identifier = userInfo["RealityKit.NotificationTrigger.Identifier"] as? String
            else { return }

            switch identifier {
            case "Arrived":
                print("Timeline RCP mengirim: Arrived")
                appModel.gameViewModel.handleNpcArrived()
            default:
                break
            }
        }
        .task {
            do{
                try await HandTrackingService.shared.start()
            }catch{
                print("ada error \(error.localizedDescription)")
            }
        }
    }
}

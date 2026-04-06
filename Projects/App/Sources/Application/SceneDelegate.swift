//
//  SceneDelegate.swift
//  PinIt
//
//  Created by 서정원 on 3/3/26.
//

import Data
import UIKit
import Presentation

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private let diContainer = AppDIContainer()
    private var appFlowController: AppFlowController?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        let appFlowController = AppFlowController(
            window: window,
            diContainer: diContainer,
            authSessionRepository: DefaultAuthSessionRepository()
        )
        appFlowController.start()

        self.appFlowController = appFlowController
        self.window = window
    }
}

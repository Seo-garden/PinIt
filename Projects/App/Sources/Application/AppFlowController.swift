//
//  AppFlowController.swift
//  App
//
//  Created by Codex on 3/24/26.
//

import Presentation
import UIKit

@MainActor
final class AppFlowController {
    private enum AppLaunchFlow {
        case onboarding
        case login
        case main
    }

    private weak var window: UIWindow?
    private let diContainer: AppDIContainer
    private let authSessionRepository: any AuthSessionInterface
    private let defaults: UserDefaults

    private static let hasCompletedOnboardingKey = "hasCompletedOnboarding"

    init(
        window: UIWindow,
        diContainer: AppDIContainer,
        authSessionRepository: any AuthSessionInterface = AuthSessionRepository(),
        defaults: UserDefaults = .standard
    ) {
        self.window = window
        self.diContainer = diContainer
        self.authSessionRepository = authSessionRepository
        self.defaults = defaults
    }

    func start() {
        transition(to: initialFlow(), animated: false)
    }

    private func initialFlow() -> AppLaunchFlow {
        let hasCompletedOnboarding = defaults.object(forKey: Self.hasCompletedOnboardingKey) as? Bool ?? false

        guard hasCompletedOnboarding else {
            return .onboarding
        }

        return authSessionRepository.isSignedIn() ? .main : .login
    }

    private func transition(to flow: AppLaunchFlow, animated: Bool) {
        let viewController: UIViewController

        switch flow {
        case .onboarding:
            viewController = diContainer.makeOnboardingViewController { [weak self] in
                self?.transition(to: .login, animated: true)
            }
        case .login:
            viewController = diContainer.makeLoginViewController { [weak self] in
                self?.transition(to: .main, animated: true)
            }
        case .main:
            viewController = diContainer.makeMainTabBarController()
        }

        setRootViewController(viewController, animated: animated)
    }

    private func setRootViewController(_ viewController: UIViewController, animated: Bool) {
        guard let window else { return }

        let updateRootViewController = {
            window.rootViewController = viewController
            window.makeKeyAndVisible()
        }

        guard animated else {
            updateRootViewController()
            return
        }

        UIView.transition(
            with: window,
            duration: 0.25,
            options: [.transitionCrossDissolve, .allowAnimatedContent],
            animations: updateRootViewController
        )
    }
}

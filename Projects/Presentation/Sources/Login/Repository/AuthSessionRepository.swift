//
//  AuthSessionRepository.swift
//  Presentation
//
//  Created by Codex on 3/24/26.
//

import FirebaseAuth
import Foundation

public protocol AuthSessionInterface {
    func isSignedIn() -> Bool
}

public struct AuthSessionRepository: AuthSessionInterface {
    public init() { }

    public func isSignedIn() -> Bool {
        guard PresentationFirebaseBootstrap.configureIfNeeded() else {
            return false
        }

        return Auth.auth().currentUser != nil
    }
}

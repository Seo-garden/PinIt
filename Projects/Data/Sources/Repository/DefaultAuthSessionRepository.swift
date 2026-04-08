//
//  DefaultAuthSessionRepository.swift
//  Data
//
//  Created by 서정원 on 4/6/26.
//

import Domain
import FirebaseAuth
import Foundation

public struct DefaultAuthSessionRepository: AuthSessionRepository {
    public init() { }

    public func isSignedIn() -> Bool {
        guard FirebaseBootstrap.configureIfNeeded() else {
            return false
        }

        return Auth.auth().currentUser != nil
    }

    public func currentUserEmail() -> String? {
        guard FirebaseBootstrap.configureIfNeeded() else { return nil }
        return Auth.auth().currentUser?.email
    }

    public func currentUserDisplayName() -> String? {
        guard FirebaseBootstrap.configureIfNeeded() else { return nil }
        return Auth.auth().currentUser?.displayName
    }
}

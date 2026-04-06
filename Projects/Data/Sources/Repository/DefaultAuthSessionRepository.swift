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
}

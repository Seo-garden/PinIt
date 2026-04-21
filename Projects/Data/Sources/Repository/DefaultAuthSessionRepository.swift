//
//  DefaultAuthSessionRepository.swift
//  Data
//
//  Created by 서정원 on 4/6/26.
//

import Domain
import Foundation

public struct DefaultAuthSessionRepository: AuthSessionRepository {
    public init() { }

    public func isSignedIn() -> Bool {
        MockAuthSessionStore.isSignedIn
    }

    public func currentUserEmail() -> String? {
        MockAuthSessionStore.email
    }

    public func currentUserDisplayName() -> String? {
        guard let email = MockAuthSessionStore.email else { return nil }
        return email.split(separator: "@").first.map(String.init)
    }
}

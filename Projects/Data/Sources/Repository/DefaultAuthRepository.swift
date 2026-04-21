//
//  DefaultAuthRepository.swift
//  Data
//
//  Created by 서정원 on 4/6/26.
//

import Domain
import Foundation

public final class DefaultAuthRepository: AuthRepository, @unchecked Sendable {
    private static let mockEmail = "test@pinit.com"
    private static let mockPassword = "password1234"
    private static let simulatedDelay: DispatchTimeInterval = .milliseconds(300)

    public init() { }

    public func signIn(email: String, password: String, completion: @escaping (Result<String, AuthError>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + Self.simulatedDelay) {
            guard email == Self.mockEmail, password == Self.mockPassword else {
                completion(.failure(.wrongCredentials))
                return
            }
            MockAuthSessionStore.email = email
            completion(.success(email))
        }
    }

    public func signOut(completion: @escaping (Result<Void, AuthError>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + Self.simulatedDelay) {
            MockAuthSessionStore.email = nil
            completion(.success(()))
        }
    }

    public func deleteAccount(completion: @escaping (Result<Void, AuthError>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + Self.simulatedDelay) {
            guard MockAuthSessionStore.email != nil else {
                completion(.failure(.userNotFound))
                return
            }
            MockAuthSessionStore.email = nil
            completion(.success(()))
        }
    }

    public func resetPassword(email: String, completion: @escaping (Result<Void, AuthError>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + Self.simulatedDelay) {
            completion(.success(()))
        }
    }
}

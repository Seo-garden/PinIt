//
//  DefaultAuthRepository.swift
//  Data
//
//  Created by 서정원 on 4/6/26.
//

import Domain
import Foundation
import FirebaseAuth
import FirebaseCore

public final class DefaultAuthRepository: AuthRepository, @unchecked Sendable {
    public init() { }

    public func signIn(email: String, password: String, completion: @escaping (Result<String, AuthError>) -> Void) {
        guard FirebaseBootstrap.configureIfNeeded() else {
            completion(.failure(.firebaseNotConfigured))
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error {
                completion(.failure(Self.map(error)))
                return
            }

            guard let email = result?.user.email else {
                completion(.failure(.missingUserEmail))
                return
            }

            completion(.success(email))
        }
    }

    public func signOut(completion: @escaping (Result<Void, AuthError>) -> Void) {
        guard FirebaseBootstrap.configureIfNeeded() else {
            completion(.failure(.firebaseNotConfigured))
            return
        }

        do {
            try Auth.auth().signOut()
            completion(.success(()))
        } catch {
            completion(.failure(.unknown))
        }
    }

    public func deleteAccount(completion: @escaping (Result<Void, AuthError>) -> Void) {
        guard FirebaseBootstrap.configureIfNeeded() else {
            completion(.failure(.firebaseNotConfigured))
            return
        }

        guard let user = Auth.auth().currentUser else {
            completion(.failure(.userNotFound))
            return
        }

        user.delete { error in
            if let error {
                completion(.failure(Self.map(error)))
            } else {
                completion(.success(()))
            }
        }
    }

    public func resetPassword(email: String, completion: @escaping (Result<Void, AuthError>) -> Void) {
        guard FirebaseBootstrap.configureIfNeeded() else {
            completion(.failure(.firebaseNotConfigured))
            return
        }

        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error {
                completion(.failure(Self.map(error)))
            } else {
                completion(.success(()))
            }
        }
    }

    private static func map(_ error: Error) -> AuthError {
        guard let errorCode = AuthErrorCode(rawValue: (error as NSError).code) else {
            return .unknown
        }

        switch errorCode {
        case .wrongPassword, .invalidCredential:
            return .wrongCredentials
        case .invalidEmail:
            return .invalidEmail
        case .userNotFound:
            return .userNotFound
        case .networkError:
            return .network
        case .tooManyRequests:
            return .tooManyRequests
        default:
            return .unknown
        }
    }
}

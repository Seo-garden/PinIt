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

    public func signIn(email: String, password: String) async throws -> String {
        guard FirebaseBootstrap.configureIfNeeded() else {
            throw AuthManagerRepositoryError.firebaseNotConfigured
        }

        return try await withCheckedThrowingContinuation { continuation in
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error {
                    continuation.resume(throwing: Self.map(error))
                    return
                }

                guard let email = result?.user.email else {
                    continuation.resume(throwing: AuthManagerRepositoryError.missingUserEmail)
                    return
                }

                continuation.resume(returning: email)
            }
        }
    }

    private static func map(_ error: Error) -> AuthManagerRepositoryError {
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

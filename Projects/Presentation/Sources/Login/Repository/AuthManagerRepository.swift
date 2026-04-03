//
//  AuthManagerRepository.swift
//  Presentation
//
//  Created by 김민우 on 3/24/26.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import RxSwift

public final class AuthManagerRepository: AuthManagerInterface {
    public init() { }

    public func signIn(email: String, password: String) -> Single<String> {
        Single.create { single in
            guard PresentationFirebaseBootstrap.configureIfNeeded() else {
                single(.failure(AuthManagerRepositoryError.firebaseNotConfigured))
                return Disposables.create()
            }

            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error {
                    single(.failure(Self.map(error)))
                    return
                }

                guard let email = result?.user.email else {
                    single(.failure(AuthManagerRepositoryError.missingUserEmail))
                    return
                }

                single(.success(email))
            }

            return Disposables.create()
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

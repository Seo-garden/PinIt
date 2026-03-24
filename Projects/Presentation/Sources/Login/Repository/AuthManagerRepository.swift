//
//  AuthManagerRepository.swift
//  Presentation
//
//  Created by 김민우 on 3/20/26.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import RxSwift

public protocol AuthManagerInterface {
    func signIn(email: String, password: String) -> Single<String>
}

public enum AuthManagerRepositoryError: LocalizedError {
    case firebaseNotConfigured
    case missingUserEmail

    public var errorDescription: String? {
        switch self {
        case .firebaseNotConfigured:
            return "Firebase 설정이 완료되지 않았습니다. App 타깃에 GoogleService-Info.plist를 추가해주세요."
        case .missingUserEmail:
            return "로그인한 사용자 정보를 확인할 수 없습니다."
        }
    }
}

public final class AuthManagerRepository: AuthManagerInterface {
    public init() { }

    public func signIn(email: String, password: String) -> Single<String> {
        Single.create { single in
            guard FirebaseApp.app() != nil else {
                single(.failure(AuthManagerRepositoryError.firebaseNotConfigured))
                return Disposables.create()
            }

            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error {
                    single(.failure(error))
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
}

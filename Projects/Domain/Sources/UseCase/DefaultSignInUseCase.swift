//
//  DefaultSignInUseCase.swift
//  Domain
//
//  Created by 서정원 on 4/6/26.
//

import Foundation

public protocol SignInUseCase {
    func execute(email: String, password: String, completion: @escaping (Result<String, AuthError>) -> Void)
}

public final class DefaultSignInUseCase: SignInUseCase {
    private let authRepository: AuthRepository

    public init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    public func execute(email: String, password: String, completion: @escaping (Result<String, AuthError>) -> Void) {
        authRepository.signIn(email: email, password: password, completion: completion)
    }
}

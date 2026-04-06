//
//  DefaultSignInUseCase.swift
//  Domain
//
//  Created by 서정원 on 4/6/26.
//

import Foundation

public protocol SignInUseCase {
    func execute(email: String, password: String) async throws -> String
}

public final class DefaultSignInUseCase: SignInUseCase {
    private let authRepository: AuthRepository

    public init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    
    public func execute(email: String, password: String) async throws -> String {
        try await authRepository.signIn(email: email, password: password)
    }
}

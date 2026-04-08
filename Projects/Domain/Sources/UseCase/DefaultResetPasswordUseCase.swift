//
//  DefaultResetPasswordUseCase.swift
//  Domain
//
//  Created by 서정원 on 4/7/26.
//

public protocol ResetPasswordUseCase: Sendable {
    func execute(email: String, completion: @escaping (Result<Void, AuthError>) -> Void)
}

public final class DefaultResetPasswordUseCase: ResetPasswordUseCase {
    private let authRepository: AuthRepository

    public init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    public func execute(email: String, completion: @escaping (Result<Void, AuthError>) -> Void) {
        authRepository.resetPassword(email: email, completion: completion)
    }
}

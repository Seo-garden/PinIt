//
//  DefaultSignOutUseCase.swift
//  Domain
//
//  Created by 서정원 on 4/7/26.
//

public protocol SignOutUseCase: Sendable {
    func execute(completion: @escaping (Result<Void, AuthError>) -> Void)
}

public final class DefaultSignOutUseCase: SignOutUseCase {
    private let authRepository: AuthRepository

    public init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    public func execute(completion: @escaping (Result<Void, AuthError>) -> Void) {
        authRepository.signOut(completion: completion)
    }
}

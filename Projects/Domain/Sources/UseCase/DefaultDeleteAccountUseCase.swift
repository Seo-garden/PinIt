//
//  DefaultDeleteAccountUseCase.swift
//  Domain
//

public protocol DeleteAccountUseCase: Sendable {
    func execute(completion: @escaping (Result<Void, AuthError>) -> Void)
}

public final class DefaultDeleteAccountUseCase: DeleteAccountUseCase {
    private let authRepository: AuthRepository

    public init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    public func execute(completion: @escaping (Result<Void, AuthError>) -> Void) {
        authRepository.deleteAccount(completion: completion)
    }
}

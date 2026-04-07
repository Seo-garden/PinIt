//
//  DefaultFetchCurrentUserUseCase.swift
//  Domain
//
//  Created by 서정원 on 4/7/26.
//

public protocol FetchCurrentUserUseCase: Sendable {
    func execute() -> CurrentUser
}

public final class DefaultFetchCurrentUserUseCase: FetchCurrentUserUseCase {
    private let authSessionRepository: AuthSessionRepository

    public init(authSessionRepository: AuthSessionRepository) {
        self.authSessionRepository = authSessionRepository
    }

    public func execute() -> CurrentUser {
        CurrentUser(
            displayName: authSessionRepository.currentUserDisplayName(),
            email: authSessionRepository.currentUserEmail()
        )
    }
}

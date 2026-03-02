import Foundation

public protocol AuthServiceProtocol {
    func login(email: String, password: String) async throws -> AuthSession
}

public struct AuthSession: Equatable, Sendable {
    public let userId: String
    public let email: String

    public init(userId: String, email: String) {
        self.userId = userId
        self.email = email
    }
}

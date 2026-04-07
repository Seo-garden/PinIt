//
//  CurrentUser.swift
//  Domain
//

public struct CurrentUser: Sendable {
    public let displayName: String?
    public let email: String?

    public init(displayName: String?, email: String?) {
        self.displayName = displayName
        self.email = email
    }
}

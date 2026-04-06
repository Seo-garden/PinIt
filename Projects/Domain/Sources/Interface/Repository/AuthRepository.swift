//
//  AuthRepository.swift
//  Domain
//
//  Created by 서정원 on 4/6/26.
//

public protocol AuthRepository: Sendable {
    func signIn(email: String, password: String) async throws -> String
}

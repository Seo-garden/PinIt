//
//  AuthRepository.swift
//  Domain
//
//  Created by 서정원 on 4/6/26.
//

public protocol AuthRepository: Sendable {
    func signIn(email: String, password: String, completion: @escaping (Result<String, AuthError>) -> Void)
    func signOut(completion: @escaping (Result<Void, AuthError>) -> Void)
    func deleteAccount(completion: @escaping (Result<Void, AuthError>) -> Void)
    func resetPassword(email: String, completion: @escaping (Result<Void, AuthError>) -> Void)
}

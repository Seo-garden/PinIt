//
//  MockAuthSessionStore.swift
//  Data
//
//  Created by 서정원 on 4/21/26.
//

import Foundation

enum MockAuthSessionStore {
    private static let emailKey = "mock.auth.email"
    private static let defaults = UserDefaults.standard

    static var email: String? {
        get { defaults.string(forKey: emailKey) }
        set {
            if let newValue {
                defaults.set(newValue, forKey: emailKey)
            } else {
                defaults.removeObject(forKey: emailKey)
            }
        }
    }

    static var isSignedIn: Bool { email != nil }
}

//
//  FirebaseBootstrap.swift
//  Data
//
//  Created by 서정원 on 4/6/26.
//

import Foundation
import FirebaseCore

public enum FirebaseBootstrap {
    @discardableResult
    public static func configureIfNeeded() -> Bool {
        if FirebaseApp.isDefaultAppConfigured() {
            return true
        }

        guard let path = Bundle.module.path(forResource: "GoogleService-Info", ofType: "plist") else {
            return false
        }

        guard let options = FirebaseOptions(contentsOfFile: path) else {
            return false
        }

        FirebaseApp.configure(options: options)
        return FirebaseApp.isDefaultAppConfigured()
    }
}

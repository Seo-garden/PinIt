//
//  PresentationFirebaseBootstrap.swift
//  Presentation
//
//  Created by 김민우 on 3/24/26.
//

import Foundation
import FirebaseCore

enum PresentationFirebaseBootstrap {
    @discardableResult
    static func configureIfNeeded() -> Bool {
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

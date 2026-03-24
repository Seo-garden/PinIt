//
//  LocalOnboardingFake.swift
//  Presentation
//
//  Created by 김민우 on 3/13/26.
//

import Foundation


// MARK: fake
internal actor LocalOnboardingFake: LocalOnboaringInterface {
    private(set) var hasCompletedOnboarding: Bool? = nil

    func setHasCompletedOnboarding(_ value: Bool) async {
        hasCompletedOnboarding = value
    }

    func loadStatus() async { }

    func saveStatus() async { }
}

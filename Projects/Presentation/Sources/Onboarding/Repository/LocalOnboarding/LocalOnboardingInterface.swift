//
//  LocalOnboardingInterface.swift
//  Presentation
//
//  Created by 김민우 on 3/13/26.
//

import Foundation


// MARK: interface
protocol LocalOnboaringInterface: Sendable {
    var hasCompletedOnboarding: Bool? { get async }

    func setHasCompletedOnboarding(_ value: Bool) async
    func loadStatus() async
    func saveStatus() async
}

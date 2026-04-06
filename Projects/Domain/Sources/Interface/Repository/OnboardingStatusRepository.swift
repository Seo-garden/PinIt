//
//  OnboardingStatusRepository.swift
//  Domain
//
//  Created by 서정원 on 4/6/26.
//

public protocol OnboardingStatusRepository: Sendable {
    func hasCompletedOnboarding() async -> Bool
    func setCompleted(_ value: Bool) async
}

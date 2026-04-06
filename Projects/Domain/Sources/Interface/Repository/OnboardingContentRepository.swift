//
//  OnboardingContentRepository.swift
//  Domain
//
//  Created by 서정원 on 4/6/26.
//

public protocol OnboardingContentRepository: Sendable {
    func fetchContent() async -> OnboardingContent?
}

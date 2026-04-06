//
//  DefaultOnboardingStatusRepository.swift
//  Data
//
//  Created by 서정원 on 4/6/26.
//

import Domain
import Foundation
import OSLog

public final class DefaultOnboardingStatusRepository: OnboardingStatusRepository, @unchecked Sendable {
    private let logger = Logger()
    private let defaults: UserDefaults
    private let hasCompletedOnboardingKey = "hasCompletedOnboarding"

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public func hasCompletedOnboarding() async -> Bool {
        let status = defaults.object(forKey: hasCompletedOnboardingKey) as? Bool ?? false
        logger.debug("온보딩 상태 불러오기 완료: \(status, privacy: .public)")
        return status
    }

    public func setCompleted(_ value: Bool) async {
        defaults.set(value, forKey: hasCompletedOnboardingKey)
        logger.debug("온보딩 상태 저장 완료: \(value, privacy: .public)")
    }
}

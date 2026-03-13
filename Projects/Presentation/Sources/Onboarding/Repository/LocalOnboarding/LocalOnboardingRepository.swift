//
//  LocalOnboardingRepository.swift
//  Presentation
//
//  Created by 김민우 on 3/12/26.
//

import Foundation
import OSLog


// MARK: value
actor LocalOnboardingRepository: LocalOnboaringInterface {
    // MARK: core
    private let logger = Logger()
    private let defaults: UserDefaults
    private let hasCompletedOnboardingKey = "hasCompletedOnboarding"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }


    // MARK: state
    private(set) var hasCompletedOnboarding: Bool? = nil
    func setHasCompletedOnboarding(_ value: Bool) {
        hasCompletedOnboarding = value
    }


    // MARK: action
    func loadStatus() async {
        // capture
        
        
        // process
        let status = defaults.object(forKey: hasCompletedOnboardingKey) as? Bool
        
        // mutate
        hasCompletedOnboarding = status

        logger.debug(
            "온보딩 상태 불러오기 완료: \(String(describing: status), privacy: .public)"
        )
    }
    func saveStatus() async {
        // capture
        guard let hasCompletedOnboarding else {
            logger.error("`hasCompletedOnboarding`이 `nil`이 될 수 없습니다.")
            return
        }
        
        // process
        defaults.set(hasCompletedOnboarding, forKey: hasCompletedOnboardingKey)

        logger.debug(
            "온보딩 상태 저장 완료: \(hasCompletedOnboarding, privacy: .public)"
        )
        
        
        // mutate
    }
}

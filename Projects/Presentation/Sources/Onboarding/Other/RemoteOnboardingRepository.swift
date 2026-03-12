//
//  RemoteOnboardingRepository.swift
//  Presentation
//
//  Created by 김민우 on 3/13/26.
//

import Foundation
import OSLog


// MARK: object
actor RemoteOnboardingRepository {
    // MARK: core
    private let logger = Logger()
    
    
    // MARK: state
    var onboardingContent: OnboardingContent? = nil
    
    
    // MARK: action
    func fetchContent() async {
        fatalError("구현 예정")
    }
    
    
    // MARK: value
}

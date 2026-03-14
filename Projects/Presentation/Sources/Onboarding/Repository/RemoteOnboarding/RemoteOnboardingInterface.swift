//
//  RemoteOnboardingInterface.swift
//  Presentation
//
//  Created by 김민우 on 3/13/26.
//

import Foundation


// MARK: interface
public protocol RemoteOnboardingInterface: Sendable {
    // MARK: state
    var onboardingContent: OnboardingContent? { get async }

    
    // MARK: action
    func fetchContent() async
}

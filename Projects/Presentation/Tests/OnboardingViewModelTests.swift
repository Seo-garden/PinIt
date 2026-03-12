//
//  OnboardingViewModelTests.swift
//  Presentation
//
//  Created by 김민우 on 3/13/26.
//

import Foundation
import Testing
@testable import Presentation


// MARK: Tests
@Suite("OnboardingViewModel")
struct OnboardingViewModelTests {
    struct Init {
        let onboardingViewModel: OnboardingViewModel
        init() async throws {
            self.onboardingViewModel = await OnboardingViewModel()
        }
        
        @Test func pagesAreEmpty() async throws {
            // then
            await #expect(onboardingViewModel.pages.isEmpty == true)
        }
        @Test func currentPagesIsNil() async throws {
            // then
            await #expect(onboardingViewModel.currentPage == nil)
        }
    }
}


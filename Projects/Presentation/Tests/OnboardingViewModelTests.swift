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
            await #expect(onboardingViewModel.pageContents.isEmpty == true)
        }
        @Test func currentPagesIsNil() async throws {
            // then
            await #expect(onboardingViewModel.currentPage == nil)
        }
    }
    
    struct FetchInfoPages {
        let onboardingViewModel: OnboardingViewModel
        init() async throws {
            self.onboardingViewModel = await OnboardingViewModel()
        }
        
        @Test func appendPages() async throws {
            // given
            try await #require(onboardingViewModel.pageContents.isEmpty == true)
            
            // when
            await onboardingViewModel.fetchContent()
            
            // then
            await #expect(onboardingViewModel.pageContents.isEmpty == false)
        }
        @Test func whenAlreadyFetched() async throws {
            // given
            try await #require(onboardingViewModel.pageContents.isEmpty)
            
            await onboardingViewModel.fetchContent()
            
            try await #require(onboardingViewModel.pageContents.isEmpty == false)
            
            let pageContents = await onboardingViewModel.pageContents
            
            // when
            await onboardingViewModel.fetchContent()
            
            // then
            let newPageContents = await onboardingViewModel.pageContents
            
            #expect(newPageContents == pageContents)
        }
        
        @Test func setCurrentPage() async throws {
            // given
            try await #require(onboardingViewModel.currentPage == nil)
            
            // when
            await onboardingViewModel.fetchContent()
            
            // then
            await #expect(onboardingViewModel.currentPage != nil)
        }
        @Test func setCurrentPageToFirstPage() async throws {
            // when
            await onboardingViewModel.fetchContent()
            
            // then
            let currentPage = try #require(await onboardingViewModel.currentPage)
            
            #expect(currentPage.index == 0)
        }
    }
    
    
    struct Next {
        let onboardingViewModel: OnboardingViewModel
        init() async throws {
            self.onboardingViewModel = await OnboardingViewModel()
        }
        
        @Test func setCurrentPageToNextPage() async throws {
            // given
            await onboardingViewModel.fetchContent()
            let currentPage = try #require(await onboardingViewModel.currentPage)
            #expect(currentPage.index == 0)
            
            // when
            await onboardingViewModel.next()
            
            // then
            let nextPage = try #require(await onboardingViewModel.currentPage)
            #expect(nextPage.index == 1)
            #expect(await onboardingViewModel.isLastPage == false)
        }
    }
}

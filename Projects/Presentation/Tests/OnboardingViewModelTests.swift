//
//  OnboardingViewModelTests.swift
//  Presentation
//
//  Created by 김민우 on 3/13/26.
//

import Domain
import Foundation
import Testing
@testable import Presentation


// MARK: - Fake Repositories

private struct FakeOnboardingContentRepository: OnboardingContentRepository {
    func fetchContent() async -> OnboardingContent? {
        OnboardingContent(
            version: 1,
            pages: [
                .init(index: 0, headline: "페이지 1", imageURL: nil),
                .init(index: 1, headline: "페이지 2", imageURL: nil),
                .init(index: 2, headline: "페이지 3", imageURL: nil),
                .init(index: 3, headline: "페이지 4", imageURL: nil),
                .init(index: 4, headline: "페이지 5", imageURL: nil)
            ]
        )
    }
}

private final class FakeOnboardingStatusRepository: OnboardingStatusRepository, @unchecked Sendable {
    private var completed = false

    func hasCompletedOnboarding() async -> Bool {
        completed
    }

    func setCompleted(_ value: Bool) async {
        completed = value
    }
}


// MARK: Tests
@Suite("OnboardingViewModel")
struct OnboardingViewModelTests {
    private static func makeViewModel() async -> OnboardingViewModel {
        await OnboardingViewModel(
            onboardingContentRepo: FakeOnboardingContentRepository(),
            onboardingStatusRepo: FakeOnboardingStatusRepository()
        )
    }

    struct Init {
        let onboardingViewModel: OnboardingViewModel
        init() async throws {
            self.onboardingViewModel = await OnboardingViewModelTests.makeViewModel()
        }

        @Test func pagesAreEmpty() async throws {
            // then
            await #expect(onboardingViewModel.pageContents.isEmpty == true)
        }
        @Test func currentPagesIsNil() async throws {
            // then
            await #expect(onboardingViewModel.currentPage == nil)
        }
        @Test func setIsFinishedFalse() async throws {
            // then
            await #expect(onboardingViewModel.isFinished == false)
        }
    }

    struct FetchInfoPages {
        let onboardingViewModel: OnboardingViewModel
        init() async throws {
            self.onboardingViewModel = await OnboardingViewModelTests.makeViewModel()
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

        @Test func setIsContentFetchedTrue() async throws {
            // given
            try await #require(onboardingViewModel.isContentFetched == false)

            // when
            await onboardingViewModel.fetchContent()

            // then
            await #expect(onboardingViewModel.isContentFetched == true)
        }
    }


    struct Next {
        let onboardingViewModel: OnboardingViewModel
        init() async throws {
            self.onboardingViewModel = await OnboardingViewModelTests.makeViewModel()
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
        @Test func setIsLastPageTrue() async throws {
            // given
            await onboardingViewModel.fetchContent()

            let pageCount = await onboardingViewModel.pageContents.count
            let nextCount = pageCount - 1

            for _ in 1...nextCount-1 {
                await onboardingViewModel.next()
            }

            try await #require(onboardingViewModel.isLastPage == false)

            // when
            await onboardingViewModel.next()

            // then
            await #expect(onboardingViewModel.isLastPage == true)
        }

        @Test func returnToFirstPageWhenLastPage() async throws {
            // given
            await onboardingViewModel.fetchContent()

            let pageCount = await onboardingViewModel.pageContents.count
            let nextCount = pageCount - 1

            for _ in 1...nextCount {
                await onboardingViewModel.next()
            }

            try await #require(onboardingViewModel.isLastPage == true)

            // when
            await onboardingViewModel.next()

            // then
            await #expect(onboardingViewModel.isLastPage == false)

            let currentPage = try #require(await onboardingViewModel.currentPage)
            #expect(currentPage.index == 0)
        }
    }

    struct FinishOnboarding {
        let onboardingViewModel: OnboardingViewModel
        init() async throws {
            self.onboardingViewModel = await OnboardingViewModelTests.makeViewModel()
        }
    }
}

//
//  OnboardingViewModel.swift
//  Presentation
//
//  Created by 김민우 on 3/12/26.
//

import Domain
import Foundation
import RxSwift
import OSLog
import Expose


// MARK: object
@MainActor @Exposable
public final class OnboardingViewModel {
    // MARK: core
    private let logger = Logger()
    private let onboardingContentRepo: OnboardingContentRepository
    private let onboardingStatusRepo: OnboardingStatusRepository

    public init(
        onboardingContentRepo: OnboardingContentRepository,
        onboardingStatusRepo: OnboardingStatusRepository
    ) {
        self.onboardingContentRepo = onboardingContentRepo
        self.onboardingStatusRepo = onboardingStatusRepo
    }


    // MARK: state
    @Exposed public private(set) var pageContents: [OnboardingContent.Page] = []
    public var isContentFetched: Bool {
        self.pageContents.isEmpty == false
    }

    @Exposed public var currentPage: OnboardingContent.Page? = nil
    @Exposed public var isLastPage: Bool = false

    @Exposed public var isFinished: Bool = false


    // MARK: action
    public func fetchContent() async {
        // capture
        guard self.isContentFetched == false else {
            logger.error("이미 content가 업데이트된 상태입니다.")
            return
        }

        // compute
        let content = await onboardingContentRepo.fetchContent()

        let pageContents = content?.pages
        let firstPage = pageContents?.first { $0.index == 0 }

        // mutate
        self.pageContents = pageContents ?? []
        self.currentPage = firstPage
        self.isLastPage = (firstPage?.index == self.pageContents.count - 1)
    }

    public func next() async {
        // capture
        guard let currentPage else {
            logger.error("현재 페이지가 없습니다. 먼저 fetchContent()를 호출해주세요.")
            return
        }

        let pageContents = self.pageContents
        let pageCount = pageContents.count



        // compute
        let nextIndex: Int = {
            if currentPage.index == pageCount - 1 {
                return 0
            } else {
                return currentPage.index + 1
            }
        }()

        let isNextPageLast = (nextIndex == pageCount - 1)

        let nextPage = pageContents.first { $0.index == nextIndex }

        guard let nextPage else {
            logger.error("\(nextIndex)에 해당하는 다음 페이지가 존재하지 않습니다.")
            return
        }


        // mutate
        self.currentPage = nextPage
        self.isLastPage = isNextPageLast
    }
    public func finishOnboarding() async {
        await onboardingStatusRepo.setCompleted(true)
        isFinished = true
    }


    // MARK: value
}

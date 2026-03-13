//
//  OnboardingViewModel.swift
//  Presentation
//
//  Created by 김민우 on 3/12/26.
//

import Foundation
import RxSwift
import OSLog
import Expose


// MARK: object
@MainActor @Exposable
public final class OnboardingViewModel {
    // MARK: core
    private let logger = Logger()
    
    public init(mode: AppMode = .debug) {
        switch mode {
        case .debug:
            self.localOnboardingRepo = LocalOnboardingRepository()
            self.remoteOnboardingRepo = RemoteOnboardingRepository()
        case .release:
            self.localOnboardingRepo = LocalOnboardingFake()
            self.remoteOnboardingRepo = RemoteOnboardingRepository()
        }
    }
    
    
    // MARK: state
    internal let localOnboardingRepo: any LocalOnboaringInterface
    internal let remoteOnboardingRepo: any RemoteOnboardingInterface
    
    @Exposed public private(set) var pageContents: [OnboardingContent.Page] = []
    public var isContentFetched: Bool {
        self.pageContents.isEmpty == false
    }
    
    public var currentPage: OnboardingContent.Page? = nil
    public var isLastPage: Bool = false
    
    
    // MARK: action
    public func fetchContent() async {
        // capture
        guard self.isContentFetched == false else {
            logger.error("이미 content가 업데이트된 상태입니다.")
            return
        }
        
        // compute
        await remoteOnboardingRepo.fetchContent()
        
        let content = await remoteOnboardingRepo.onboardingContent
        
        // mutate
        self.pageContents = content?.pages ?? []
    }
    
    public func next() async {
        // mutate
        logger.error("구현 예정입니다.")
    }
    public func skip() async {
        logger.error("구현 예정입니다.")
    }
    
    
    // MARK: value
}

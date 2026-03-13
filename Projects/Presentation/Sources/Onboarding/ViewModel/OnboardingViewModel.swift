//
//  OnboardingViewModel.swift
//  Presentation
//
//  Created by 김민우 on 3/12/26.
//

import Foundation
import RxSwift
import OSLog


// MARK: object
@MainActor
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
    
    public var pages: [InfoPageViewModel] = []
    public var currentPage: InfoPageViewModel? = nil
    
    
    // MARK: action
    public func fetchInfoPages() async {
        // capture
        guard self.pages.isEmpty == true else {
            logger.error("이미 pages 프로퍼티가 업데이트된 상태입니다. 현재 \(self.pages.count)개의 페이지가 있습니다.")
            return
        }

        // compute
        await remoteOnboardingRepo.fetchContent()

        let content = await remoteOnboardingRepo.onboardingContent
        

        


        // mutate
        guard let content else {
            logger.error("온보딩 컨텐츠를 불러오지 못했습니다.")
            return
        }
        
        let pages = content.pages
            .map { pageContent in
                InfoPageViewModel(
                    owner: self,
                    headLine: pageContent.headline,
                    imageURL: pageContent.imageURL)
            }
        
        self.pages = pages
        self.currentPage = pages.first
        
    }
    
    
    // MARK: value
}

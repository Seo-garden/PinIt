//
//  RemoteOnboardingRepository.swift
//  Presentation
//
//  Created by 김민우 on 3/13/26.
//

import Foundation
import OSLog


// MARK: object
actor RemoteOnboardingRepository: RemoteOnboardingInterface {
    // MARK: core
    private let logger = Logger()
    private static let fetchDelay: Duration = .milliseconds(300)
    private static let dummyContent = OnboardingContent(
        version: 1,
        pages: [
            .init(
                id: "onboarding-login",
                headline: "소셜 로그인으로 빠르게 앱을 시작해보세요.",
                imageURL: nil
            ),
            .init(
                id: "onboarding-record",
                headline: "사진, 캡션, 장소를 담아 하나의 기록으로 저장할 수 있어요.",
                imageURL: nil
            ),
            .init(
                id: "onboarding-location",
                headline: "장소를 직접 입력하거나 사진 정보를 활용해 더 쉽게 설정할 수 있어요.",
                imageURL: nil
            ),
            .init(
                id: "onboarding-map",
                headline: "저장한 기록을 지도 위에서 한눈에 다시 확인해보세요.",
                imageURL: nil
            ),
            .init(
                id: "onboarding-start",
                headline: "이제 나만의 장소 기록을 시작해보세요.",
                imageURL: nil
            )
        ]
    )
    
    
    // MARK: state
    var onboardingContent: OnboardingContent? = nil
    
    
    // MARK: action
    func fetchContent() async {
        logger.debug("온보딩 컨텐츠 더미 fetch 시작")
        
        do {
            try await Task.sleep(for: Self.fetchDelay)
        } catch {
            logger.error("온보딩 컨텐츠 더미 fetch 대기 중 취소됨")
            return
        }
        
        onboardingContent = Self.dummyContent
        logger.debug("온보딩 컨텐츠 더미 fetch 완료: \(Self.dummyContent.pages.count, privacy: .public)개 페이지")
    }
    
    
    // MARK: value
}

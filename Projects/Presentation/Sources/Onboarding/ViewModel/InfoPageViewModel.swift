//
//  InfoPageViewModel.swift
//  Presentation
//
//  Created by 김민우 on 3/12/26.
//

import Foundation
import RxSwift
import OSLog


// MARK: object
@MainActor
public final class InfoPageViewModel {
    // MARK: core
    private let logger = Logger()
    
    public init(owner: OnboardingViewModel, headLine: String, imageURL: String?) {
        self.owner = owner
        self.headLine = headLine
        self.imageURL = imageURL
    }
    
    
    // MARK: statea
    internal weak var owner: OnboardingViewModel?
    
    public let headLine: String
    public let imageURL: String?
    
    
    // MARK: action
    public func next() {
        fatalError("구현 예정")
    }
    
    
    // MARK: value
}

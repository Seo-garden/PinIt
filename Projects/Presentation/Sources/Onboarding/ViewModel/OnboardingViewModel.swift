//
//  OnboardingViewModel.swift
//  Presentation
//
//  Created by 김민우 on 3/12/26.
//

import Foundation
import RxSwift


// MARK: object
@MainActor
public final class OnboardingViewModel {
    // MARK: core
    
    
    // MARK: state
    public var pages: [InfoPageViewModel] = []
    public var currentPage: InfoPageViewModel? = nil
    
    
    // MARK: action
    public func fetchInfoPages() async {
        fatalError("구현 예정")
    }
    
    
    // MARK: value
}

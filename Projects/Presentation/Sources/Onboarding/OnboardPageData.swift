//
//  OnboardPageData.swift
//  Presentation
//
//  Created by 김민우 on 3/12/26.
//

import Foundation


// MARK: value
public nonisolated struct OnboardPageData: Sendable, Hashable,Codable {
    public let title: String
    
    public let body: [String]
    public let image: Data?
}

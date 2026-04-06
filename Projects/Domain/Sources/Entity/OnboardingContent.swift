//
//  OnboardingContent.swift
//  Presentation
//
//  Created by 김민우 on 3/12/26.
//

import Foundation


// MARK: value
public struct OnboardingContent: Sendable, Hashable, Codable {
    public let version: Int
    public let pages: [Page]

    public init(
        version: Int,
        pages: [Page]
    ) {
        self.version = version
        self.pages = pages
    }
    
    public struct Page: Codable, Sendable, Hashable {
        public let index: Int
        public let headline: String
        public let imageURL: String?
        
        public init(index: Int, headline: String, imageURL: String?) {
            self.index = index
            self.headline = headline
            self.imageURL = imageURL
        }
    }
}

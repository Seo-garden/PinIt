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
    
    public struct Page: Codable, Sendable, Hashable, Identifiable {
        public let id: String
        public let headline: String
        public let imageURL: String?
        
        public init(id: String, headline: String, imageURL: String?) {
            self.id = id
            self.headline = headline
            self.imageURL = imageURL
        }
    }
}

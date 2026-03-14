//
//  LocationSuggestionUseCase.swift
//  Domain
//
//  Created by 서정원 on 3/14/26.
//

import Foundation

public protocol LocationSuggestionUseCase {
    func resolve(from photos: [PhotoData], completion: @escaping ([SuggestedLocation]) -> Void)
    func resolve(from photos: [PhotoData]) async -> [SuggestedLocation]
}

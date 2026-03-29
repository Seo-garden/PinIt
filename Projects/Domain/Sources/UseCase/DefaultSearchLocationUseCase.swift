//
//  SearchLocationUseCase.swift
//  Domain
//
//  Created by 서정원 on 3/26/26.
//

import Foundation

public protocol SearchLocationUseCase {
    func execute(query: String, completion: @escaping (Result<[LocationSearchResult], LocationError>) -> Void)
}

public struct DefaultSearchLocationUseCase: SearchLocationUseCase {
    private let repository: LocationSearchRepository

    public init(repository: LocationSearchRepository) {
        self.repository = repository
    }

    public func execute(query: String, completion: @escaping (Result<[LocationSearchResult], LocationError>) -> Void) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            completion(.success([]))
            return
        }
        repository.search(query: trimmed, completion: completion)
    }
}

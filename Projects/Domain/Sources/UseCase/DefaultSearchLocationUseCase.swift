//
//  SearchLocationUseCase.swift
//  Domain
//
//  Created by 서정원 on 3/26/26.
//

import Foundation

public protocol SearchLocationUseCase {
    @discardableResult
    func execute(query: String, completion: @escaping (Result<[LocationSearchResult], LocationError>) -> Void) -> Cancellable
}

public struct DefaultSearchLocationUseCase: SearchLocationUseCase {
    private let repository: LocationSearchRepository

    public init(repository: LocationSearchRepository) {
        self.repository = repository
    }

    @discardableResult
    public func execute(query: String, completion: @escaping (Result<[LocationSearchResult], LocationError>) -> Void) -> Cancellable {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            completion(.success([]))
            return EmptyCancellable()
        }
        return repository.search(query: trimmed, completion: completion)
    }
}

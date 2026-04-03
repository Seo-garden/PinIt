//
//  DefaultFetchAllRecordsUseCase.swift
//  Domain
//
//  Created by 서정원 on 4/2/26.
//

import Foundation

public protocol FetchAllRecordsUseCase: Sendable {
    func execute(completion: @escaping (Result<[Record], Error>) -> Void)
}

public final class DefaultFetchAllRecordsUseCase: FetchAllRecordsUseCase {
    private let repository: RecordRepository

    public init(repository: RecordRepository) {
        self.repository = repository
    }

    public func execute(completion: @escaping (Result<[Record], Error>) -> Void) {
        repository.fetchAll(completion: completion)
    }
}

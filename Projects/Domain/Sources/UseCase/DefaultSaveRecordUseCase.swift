//
//  DefaultSaveRecordUseCase.swift
//  Domain
//
//  Created by 서정원 on 4/2/26.
//

import Foundation

public protocol SaveRecordUseCase: Sendable {
    func execute(draft: RecordDraft, completion: @escaping (Result<Record, Error>) -> Void)
}

public final class DefaultSaveRecordUseCase: SaveRecordUseCase {
    private let repository: RecordRepository

    public init(repository: RecordRepository) {
        self.repository = repository
    }

    public func execute(draft: RecordDraft, completion: @escaping (Result<Record, Error>) -> Void) {
        repository.save(draft: draft, completion: completion)
    }
}

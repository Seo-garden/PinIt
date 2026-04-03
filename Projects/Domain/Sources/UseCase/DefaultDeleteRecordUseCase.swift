//
//  DefaultDeleteRecordUseCase.swift
//  Domain
//
//  Created by 서정원 on 4/2/26.
//

import Foundation

public protocol DeleteRecordUseCase: Sendable {
    func execute(id: String, completion: @escaping (Result<Void, Error>) -> Void)
}

public final class DefaultDeleteRecordUseCase: DeleteRecordUseCase {
    private let repository: RecordRepository

    public init(repository: RecordRepository) {
        self.repository = repository
    }

    public func execute(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        repository.delete(id: id, completion: completion)
    }
}

//
//  DefaultUpdateRecordCaptionUseCase.swift
//  Domain
//
//  Created by 서정원 on 4/2/26.
//

import Foundation

public protocol UpdateRecordCaptionUseCase: Sendable {
    func execute(id: String, caption: String, completion: @escaping (Result<Void, Error>) -> Void)
}

public final class DefaultUpdateRecordCaptionUseCase: UpdateRecordCaptionUseCase {
    private let repository: RecordRepository

    public init(repository: RecordRepository) {
        self.repository = repository
    }

    public func execute(id: String, caption: String, completion: @escaping (Result<Void, Error>) -> Void) {
        repository.updateCaption(id: id, caption: caption, completion: completion)
    }
}

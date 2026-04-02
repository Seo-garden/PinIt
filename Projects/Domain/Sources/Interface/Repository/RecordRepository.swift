//
//  RecordRepository.swift
//  Domain
//
//  Created by 서정원 on 4/2/26.
//

import Foundation

public protocol RecordRepository: Sendable {
    func save(draft: RecordDraft, completion: @escaping (Result<Record, Error>) -> Void)
    func fetchAll(completion: @escaping (Result<[Record], Error>) -> Void)
    func updateCaption(id: String, caption: String, completion: @escaping (Result<Void, Error>) -> Void)
    func delete(id: String, completion: @escaping (Result<Void, Error>) -> Void)
}

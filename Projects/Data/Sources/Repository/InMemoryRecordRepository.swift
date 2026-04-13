//
//  InMemoryRecordRepository.swift
//  Data
//
//  Created by 서정원 on 4/2/26.
//

import Domain
import Foundation

public final class InMemoryRecordRepository: RecordRepository {
    private let lock = NSLock()
    private var store: [String: Record] = [:]

    public init() {}

    public func save(draft: RecordDraft, completion: @escaping (Result<Record, Error>) -> Void) {
        let record = Record(
            id: UUID().uuidString,
            photoDataList: draft.photoDataList,
            caption: draft.caption,
            locationTitle: draft.locationTitle,
            locationName: draft.locationName,
            coordinate: draft.coordinate,
            createdAt: Date()
        )
        lock.withLock { store[record.id] = record }
        completion(.success(record))
    }

    public func fetchAll(completion: @escaping (Result<[Record], Error>) -> Void) {
        let records = lock.withLock {
            store.values.sorted { $0.createdAt > $1.createdAt }
        }
        completion(.success(records))
    }

    public func updateCaption(id: String, caption: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let result: Result<Void, Error> = lock.withLock {
            guard store[id] != nil else {
                return .failure(RecordRepositoryError.notFound)
            }
            store[id]?.caption = caption
            return .success(())
        }
        completion(result)
    }

    public func delete(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let result: Result<Void, Error> = lock.withLock {
            guard store[id] != nil else {
                return .failure(RecordRepositoryError.notFound)
            }
            store.removeValue(forKey: id)
            return .success(())
        }
        completion(result)
    }
}

// MARK: - Error

enum RecordRepositoryError: LocalizedError {
    case notFound

    var errorDescription: String? {
        switch self {
        case .notFound: return "해당 기록을 찾을 수 없습니다."
        }
    }
}

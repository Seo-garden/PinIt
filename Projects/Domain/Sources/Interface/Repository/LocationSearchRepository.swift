//
//  LocationSearchRepository.swift
//  Domain
//
//  Created by 서정원 on 3/26/26.
//

import Foundation

public protocol LocationSearchRepository {
    @discardableResult
    func search(query: String, completion: @escaping (Result<[LocationSearchResult], LocationError>) -> Void) -> Cancellable
}

//
//  FetchUserLocationUseCase.swift
//  Domain
//
//  Created by 서정원 on 3/20/26.
//

import Foundation

public protocol FetchUserLocationUseCase {
    func execute(completion: @escaping (Result<Coordinate, LocationError>) -> Void)
}

public final class DefaultFetchUserLocationUseCase: FetchUserLocationUseCase {
    private let repository: LocationRepository

    public init(repository: LocationRepository) {
        self.repository = repository
    }

    public func execute(completion: @escaping (Result<Coordinate, LocationError>) -> Void) {
        repository.requestAuthorization()
        repository.fetchCurrentLocation(completion: completion)
    }
}

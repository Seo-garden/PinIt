//
//  DefaultLoadPhotoFromImageDataUseCase.swift
//  Domain
//
//  Created by 서정원 on 4/10/26.
//

import Foundation

public protocol LoadPhotoFromImageDataUseCase: Sendable {
    func execute(items: [Data], completion: @escaping (Result<[PhotoData], PhotoError>) -> Void)
}

public final class DefaultLoadPhotoFromImageDataUseCase: LoadPhotoFromImageDataUseCase {
    private let repository: PhotoRepository

    public init(repository: PhotoRepository) {
        self.repository = repository
    }

    public func execute(items: [Data], completion: @escaping (Result<[PhotoData], PhotoError>) -> Void) {
        repository.loadFromImageData(items, completion: completion)
    }
}

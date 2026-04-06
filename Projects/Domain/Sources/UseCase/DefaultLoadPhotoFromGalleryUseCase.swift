//
//  DefaultLoadPhotoFromGalleryUseCase.swift
//  Domain
//
//  Created by 서정원 on 4/6/26.
//

import Foundation

public protocol LoadPhotoFromGalleryUseCase: Sendable {
    func execute(assetIdentifiers: [String], completion: @escaping (Result<[PhotoData], PhotoError>) -> Void)
}

public final class DefaultLoadPhotoFromGalleryUseCase: LoadPhotoFromGalleryUseCase {
    private let repository: PhotoRepository

    public init(repository: PhotoRepository) {
        self.repository = repository
    }

    public func execute(assetIdentifiers: [String], completion: @escaping (Result<[PhotoData], PhotoError>) -> Void) {
        repository.loadFromGallery(assetIdentifiers: assetIdentifiers, completion: completion)
    }
}

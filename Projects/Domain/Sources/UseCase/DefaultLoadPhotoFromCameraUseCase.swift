//
//  DefaultLoadPhotoFromCameraUseCase.swift
//  Domain
//
//  Created by 서정원 on 4/6/26.
//

import Foundation

public protocol LoadPhotoFromCameraUseCase: Sendable {
    func execute(imageData: Data, metadata: [AnyHashable: Any], completion: @escaping (Result<[PhotoData], PhotoError>) -> Void)
}

public final class DefaultLoadPhotoFromCameraUseCase: LoadPhotoFromCameraUseCase {
    private let repository: PhotoRepository

    public init(repository: PhotoRepository) {
        self.repository = repository
    }

    public func execute(imageData: Data, metadata: [AnyHashable: Any], completion: @escaping (Result<[PhotoData], PhotoError>) -> Void) {
        repository.loadFromCamera(imageData: imageData, metadata: metadata, completion: completion)
    }
}

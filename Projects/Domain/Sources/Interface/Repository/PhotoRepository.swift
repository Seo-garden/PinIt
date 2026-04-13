//
//  PhotoRepository.swift
//  Domain
//
//  Created by 서정원 on 3/13/26.
//

import Foundation

public protocol PhotoRepository: Sendable {
    func loadFromCamera(imageData: Data, metadata: [AnyHashable: Any], completion: @escaping (Result<[PhotoData], PhotoError>) -> Void)
    func loadFromGallery(assetIdentifiers: [String], completion: @escaping (Result<[PhotoData], PhotoError>) -> Void)
    func loadFromImageData(_ items: [Data], completion: @escaping (Result<[PhotoData], PhotoError>) -> Void)
}

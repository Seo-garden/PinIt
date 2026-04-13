//
//  DefaultEncodePhotosUseCase.swift
//  Domain
//
//  Created by 서정원 on 4/10/26.
//

import Foundation

public protocol EncodePhotosUseCase: Sendable {
    func execute(photos: [PhotoData], completion: @escaping ([PhotoData]) -> Void)
}

public final class DefaultEncodePhotosUseCase: EncodePhotosUseCase {
    private let encoder: PhotoEncoder
    private let quality: Double

    public init(encoder: PhotoEncoder, quality: Double = 0.9) {
        self.encoder = encoder
        self.quality = quality
    }

    public func execute(photos: [PhotoData], completion: @escaping ([PhotoData]) -> Void) {
        let encoder = self.encoder
        let quality = self.quality
        DispatchQueue.global(qos: .userInitiated).async {
            let encoded = photos.map { photo -> PhotoData in
                autoreleasepool {
                    let newData = encoder.encodeToJPEGIfNeeded(photo.imageData, quality: quality)
                    return PhotoData(imageData: newData, coordinate: photo.coordinate)
                }
            }
            DispatchQueue.main.async {
                completion(encoded)
            }
        }
    }
}

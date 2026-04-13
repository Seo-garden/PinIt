//
//  DefaultPhotoEncoder.swift
//  Data
//
//  Created by 서정원 on 4/10/26.
//

import Domain
import Foundation
import ImageIO
import UniformTypeIdentifiers

public struct DefaultPhotoEncoder: PhotoEncoder {
    public init() {}

    public func encodeToJPEGIfNeeded(_ imageData: Data, quality: Double) -> Data {
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil),
              let typeIdentifier = CGImageSourceGetType(source) else {
            return imageData
        }

        // 이미 JPEG 면 추가 인코딩 없이 원본 유지 (카메라 경로의 즉시 인코딩 결과 등)
        if (typeIdentifier as String) == UTType.jpeg.identifier {
            return imageData
        }

        guard let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            return imageData
        }

        let sourceProperties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any]
        let orientation = sourceProperties?[kCGImagePropertyOrientation] as? UInt32 ?? 1

        let outputData = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            outputData,
            UTType.jpeg.identifier as CFString,
            1,
            nil
        ) else {
            return imageData
        }

        let options: [CFString: Any] = [
            kCGImageDestinationLossyCompressionQuality: quality,
            kCGImagePropertyOrientation: orientation
        ]
        CGImageDestinationAddImage(destination, cgImage, options as CFDictionary)

        guard CGImageDestinationFinalize(destination) else {
            return imageData
        }

        return outputData as Data
    }
}

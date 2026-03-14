//
//  PhotoDataDTO.swift
//  Data
//
//  Created by 서정원 on 3/14/26.
//

import Domain
import Foundation

public struct PhotoDataDTO {
    public let imageData: Data
    public let coordinate: CoordinateDTO?

    public init(imageData: Data, coordinate: CoordinateDTO?) {
        self.imageData = imageData
        self.coordinate = coordinate
    }

    public func toDomain() -> PhotoData {
        return PhotoData(
            imageData: imageData,
            coordinate: coordinate?.toDomain()
        )
    }
}

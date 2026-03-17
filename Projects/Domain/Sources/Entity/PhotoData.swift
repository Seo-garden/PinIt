//
//  PhotoData.swift
//  Domain
//
//  Created by 서정원 on 3/13/26.
//

import Foundation

public struct PhotoData: Equatable {
    public let imageData: Data
    public let coordinate: Coordinate?

    public init(imageData: Data, coordinate: Coordinate?) {
        self.imageData = imageData
        self.coordinate = coordinate
    }
}

//
//  Record.swift
//  Domain
//
//  Created by 서정원 on 4/2/26.
//

import Foundation

public struct Record: Equatable {
    public let id: String
    public let photoDataList: [PhotoData]
    public var caption: String
    public let locationName: String
    public let coordinate: Coordinate
    public let createdAt: Date

    public init(
        id: String,
        photoDataList: [PhotoData],
        caption: String,
        locationName: String,
        coordinate: Coordinate,
        createdAt: Date
    ) {
        self.id = id
        self.photoDataList = photoDataList
        self.caption = caption
        self.locationName = locationName
        self.coordinate = coordinate
        self.createdAt = createdAt
    }
}

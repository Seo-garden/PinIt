//
//  RecordDraft.swift
//  Domain
//
//  Created by 서정원 on 3/13/26.
//

import Foundation

public struct RecordDraft {
    public var photoDataList: [PhotoData]
    public var caption: String
    public var locationName: String?
    public var coordinate: Coordinate?

    public init(photoDataList: [PhotoData], caption: String, locationName: String?, coordinate: Coordinate?) {
        self.photoDataList = photoDataList
        self.caption = caption
        self.locationName = locationName
        self.coordinate = coordinate
    }
}

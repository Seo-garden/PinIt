//
//  RecordAnnotation.swift
//  Presentation
//
//  Created by 서정원 on 4/13/26.
//

import Domain
import MapKit

public final class RecordAnnotation: NSObject, MKAnnotation {
    public let records: [Record]
    public let coordinateValue: Coordinate
    public let coordinate: CLLocationCoordinate2D

    public var thumbnailData: Data? {
        records.first?.photoDataList.first?.imageData
    }

    public var recordCount: Int {
        records.count
    }

    public init(records: [Record], coordinate: Coordinate) {
        self.records = records
        self.coordinateValue = coordinate
        self.coordinate = coordinate.clLocationCoordinate2D
        super.init()
    }
}

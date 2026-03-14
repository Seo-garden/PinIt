//
//  MapRegionHelper.swift
//  Presentation
//
//  Created by 서정원 on 3/14/26.
//

import CoreLocation
import MapKit

enum MapRegionHelper {
    static let defaultLocation = CLLocationCoordinate2D(latitude: 37.5759, longitude: 126.9769) // 광화문
    static let defaultSpanMeters: CLLocationDistance = 2000
    static let targetSpanMeters: CLLocationDistance = 1200
    
    static func region(for coordinate: CLLocationCoordinate2D?) -> MKCoordinateRegion {
        if let coordinate = coordinate {
            return MKCoordinateRegion(center: coordinate, latitudinalMeters: targetSpanMeters, longitudinalMeters: targetSpanMeters)
        } else {
            return MKCoordinateRegion(center: defaultLocation, latitudinalMeters: defaultSpanMeters, longitudinalMeters: defaultSpanMeters)
        }
    }
}

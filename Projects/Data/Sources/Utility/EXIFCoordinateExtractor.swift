//
//  EXIFCoordinateExtractor.swift
//  Data
//
//  Created by 서정원 on 3/14/26.
//

import Foundation
import Domain
import ImageIO

enum EXIFCoordinateExtractor {
    static func extractCoordinate(fromData data: Data) -> CoordinateDTO? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let gps = properties[kCGImagePropertyGPSDictionary] as? [CFString: Any] else {
            return nil
        }
        return coordinate(fromGPS: gps)
    }

    static func extractCoordinate(fromMetadata metadata: [AnyHashable: Any]) -> CoordinateDTO? {
        guard let gps = metadata[kCGImagePropertyGPSDictionary] as? [CFString: Any] else { return nil }
        return coordinate(fromGPS: gps)
    }

    private static func coordinate(fromGPS gps: [CFString: Any]) -> CoordinateDTO? {
        guard let lat = gps[kCGImagePropertyGPSLatitude] as? Double,
              let lon = gps[kCGImagePropertyGPSLongitude] as? Double else { return nil }

        var latitude = lat
        if let ref = gps[kCGImagePropertyGPSLatitudeRef] as? String, ref == "S" { latitude *= -1 }
        var longitude = lon
        if let ref = gps[kCGImagePropertyGPSLongitudeRef] as? String, ref == "W" { longitude *= -1 }

        return CoordinateDTO(latitude: latitude, longitude: longitude)
    }
}

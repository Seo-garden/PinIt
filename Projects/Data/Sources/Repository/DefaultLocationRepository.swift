//
//  DefaultLocationRepository.swift
//  Data
//
//  Created by 서정원 on 3/20/26.
//

import CoreLocation
import Domain
import Foundation

public struct DefaultLocationRepository: LocationRepository {
    private let handler = LocationManagerHandler()

    public init() {}

    public func requestAuthorization() {
        handler.requestAuthorization()
    }

    public func fetchCurrentLocation(completion: @escaping (Result<Coordinate, LocationError>) -> Void) {
        handler.fetchCurrentLocation(completion: completion)
    }
}

// MARK: - LocationManagerHandler
private final class LocationManagerHandler: NSObject {
    private let locationManager = CLLocationManager()
    private var pendingCompletion: ((Result<Coordinate, LocationError>) -> Void)?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestAuthorization() {
        guard locationManager.authorizationStatus == .notDetermined else { return }
        locationManager.requestWhenInUseAuthorization()
    }

    func fetchCurrentLocation(completion: @escaping (Result<Coordinate, LocationError>) -> Void) {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            pendingCompletion = completion
            locationManager.requestLocation()
        case .denied, .restricted:
            completion(.failure(LocationError.denied))
        case .notDetermined:
            pendingCompletion = completion
        @unknown default:
            completion(.failure(LocationError.denied))
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManagerHandler: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first,
              let coordinate = Coordinate(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        else {
            pendingCompletion?(.failure(LocationError.invalidCoordinate))
            pendingCompletion = nil
            return
        }
        pendingCompletion?(.success(coordinate))
        pendingCompletion = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        pendingCompletion?(.failure(.fetchFailed))
        pendingCompletion = nil
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            guard pendingCompletion != nil else { return }
            locationManager.requestLocation()
        case .denied, .restricted:
            pendingCompletion?(.failure(LocationError.denied))
            pendingCompletion = nil
        default:
            break
        }
    }
}

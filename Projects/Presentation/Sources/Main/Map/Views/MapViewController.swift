//
//  MapViewController.swift
//  Presentation
//
//  Created by 서정원 on 3/20/26.
//

import Domain
import MapKit
import RxCocoa
import RxSwift
import UIKit

public final class MapViewController: BaseViewController<MapViewModel> {
    private let mapContainerView = MapView()

    public override func setupUI() {
        view.addSubview(mapContainerView)
        mapContainerView.translatesAutoresizingMaskIntoConstraints = false

        mapContainerView.mapView.delegate = self
        mapContainerView.mapView.register(
            RecordAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: RecordAnnotationView.reuseIdentifier
        )
    }

    public override func setupLayout() {
        NSLayoutConstraint.activate([
            mapContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            mapContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    public override func bind() {
        let input = MapViewModel.Input(
            viewDidAppear: rx.methodInvoked(#selector(viewDidAppear(_:)))
                .map { _ in }
                .asSignal(onErrorSignalWith: .empty()),
            locateMeTap: mapContainerView.locateMeButton.rx.tap.asSignal()
        )

        let output = viewModel.transform(input: input)

        output.centerLocation
            .emit(onNext: { [weak self] coordinate in
                self?.move(to: coordinate)
            })
            .disposed(by: disposeBag)

        output.panToLocation
            .emit(onNext: { [weak self] coordinate in
                self?.pan(to: coordinate)
            })
            .disposed(by: disposeBag)

        output.showLocationDeniedAlert
            .emit(onNext: { [weak self] in
                self?.showLocationSettingsAlert()
            })
            .disposed(by: disposeBag)

        output.recordAnnotations
            .emit(onNext: { [weak self] items in
                self?.updateAnnotations(items)
            })
            .disposed(by: disposeBag)
    }

    private func pan(to coordinate: Coordinate) {
        let center = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        mapContainerView.mapView.setCenter(center, animated: true)
    }

    private func move(to coordinate: Coordinate) {
        let center = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let region = MKCoordinateRegion(center: center, latitudinalMeters: 300, longitudinalMeters: 300)
        mapContainerView.mapView.setRegion(region, animated: true)
    }

    private func updateAnnotations(_ items: [MapViewModel.RecordAnnotationItem]) {
        let mapView = mapContainerView.mapView
        let existing = mapView.annotations.compactMap { $0 as? RecordAnnotation }

        let existingByKey = Dictionary(
            existing.map { ($0.coordinateValue.uniqueKey(), $0) },
            uniquingKeysWith: { first, _ in first }
        )
        let newByKey = Dictionary(
            items.map { ($0.coordinate.uniqueKey(), $0) },
            uniquingKeysWith: { first, _ in first }
        )

        var toRemove: [RecordAnnotation] = []
        var toAdd: [RecordAnnotation] = []

        for (key, annotation) in existingByKey {
            guard let newItem = newByKey[key] else {
                toRemove.append(annotation)
                continue
            }
            if annotation.records.map(\.id) != newItem.records.map(\.id) {
                toRemove.append(annotation)
                toAdd.append(RecordAnnotation(records: newItem.records, coordinate: newItem.coordinate))
            }
        }

        for (key, newItem) in newByKey where existingByKey[key] == nil {
            toAdd.append(RecordAnnotation(records: newItem.records, coordinate: newItem.coordinate))
        }

        mapView.removeAnnotations(toRemove)
        mapView.addAnnotations(toAdd)
    }

    private func showLocationSettingsAlert() {
        let alert = UIAlertController(
            title: AppStrings.Map.locationDeniedTitle,
            message: AppStrings.Map.locationDeniedMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: AppStrings.Common.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: AppStrings.Common.openSettings, style: .default) { _ in
            guard let url = URL(string: UIApplication.openSettingsURLString),
                  UIApplication.shared.canOpenURL(url) else { return }
            UIApplication.shared.open(url)
        })
        present(alert, animated: true)
    }
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let recordAnnotation = annotation as? RecordAnnotation else { return nil }

        let view = mapView.dequeueReusableAnnotationView(
            withIdentifier: RecordAnnotationView.reuseIdentifier,
            for: recordAnnotation
        ) as! RecordAnnotationView

        view.configure(with: recordAnnotation)
        return view
    }
}

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

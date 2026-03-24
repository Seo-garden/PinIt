//
//  MapView.swift
//  Presentation
//
//  Created by 서정원 on 3/20/26.
//

import MapKit
import UIKit

final class MapView: UIView {
    let mapView: MKMapView = {
        let map = MKMapView()
        map.showsUserLocation = true
        return map
    }()

    let locateMeButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "location.fill")
        config.baseBackgroundColor = .white
        config.baseForegroundColor = .systemBlue
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        let button = UIButton(configuration: config)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.15
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        return button
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(mapView)
        addSubview(locateMeButton)
        
        [mapView, locateMeButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: topAnchor),
            mapView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: bottomAnchor),

            locateMeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            locateMeButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
}

//
//  LocationSearchView.swift
//  Presentation
//
//  Created by 서정원 on 3/24/26.
//

import MapKit
import UIKit

final class LocationSearchView: UIView {
    let searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "장소를 검색해보세요"
        textField.borderStyle = .none
        textField.backgroundColor = .secondarySystemBackground
        textField.layer.cornerRadius = 12
        textField.font = .systemFont(ofSize: 16)
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .search
        let iconView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        iconView.tintColor = .secondaryLabel
        iconView.contentMode = .scaleAspectFit
        iconView.frame = CGRect(x: 8, y: 0, width: 20, height: 20)
        let paddingContainer = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 20))
        paddingContainer.addSubview(iconView)
        textField.leftView = paddingContainer
        textField.leftViewMode = .always
        return textField
    }()

    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.keyboardDismissMode = .onDrag
        tableView.rowHeight = 56
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return tableView
    }()

    let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.layer.cornerRadius = 12
        mapView.clipsToBounds = true
        mapView.isUserInteractionEnabled = false
        return mapView
    }()

    let selectButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("선택하기", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 14
        button.isEnabled = false
        button.alpha = 0.5
        return button
    }()

    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        return view
    }()

    private let bottomContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .systemBackground
        [searchTextField, tableView, divider, bottomContainer].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        [mapView, selectButton].forEach {
            bottomContainer.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            searchTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            searchTextField.heightAnchor.constraint(equalToConstant: 44),

            tableView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),

            divider.topAnchor.constraint(equalTo: tableView.bottomAnchor),
            divider.leadingAnchor.constraint(equalTo: leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale),

            bottomContainer.topAnchor.constraint(equalTo: divider.bottomAnchor),
            bottomContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomContainer.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.35),

            mapView.topAnchor.constraint(equalTo: bottomContainer.topAnchor, constant: 12),
            mapView.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor, constant: 16),
            mapView.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor, constant: -16),

            selectButton.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 12),
            selectButton.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor, constant: 16),
            selectButton.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor, constant: -16),
            selectButton.bottomAnchor.constraint(equalTo: bottomContainer.bottomAnchor, constant: -12),
            selectButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}

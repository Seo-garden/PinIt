//
//  RecordView.swift
//  Presentation
//
//  Created by 서정원 on 3/13/26.
//

import Domain
import MapKit
import UIKit

enum RecordViewMode {
    case create
    case detail
}

final class RecordView: UIView {
    // MARK: - State
    private let mode: RecordViewMode
    var suggestionButtons: [UIButton] {
        guard mode == .create else { return [] }
        return chipButtons
    }
    // MARK: - UI
    let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = true
        view.alwaysBounceVertical = true
        return view
    }()

    let contentView: UIView = {
        let view = UIView()
        return view
    }()

    let photoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.secondarySystemBackground
        view.layer.cornerRadius = 18
        view.clipsToBounds = true
        return view
    }()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.isPagingEnabled = true
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = .clear
        return view
    }()
    
    let photoEmptyLabel: UILabel = {
        let label = UILabel()
        label.text = "카메라 혹은 갤러리를 통해 사진을 첨부해보세요!"
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    let pageBadgeLabel: UILabel = {
        let label = UILabel()
        label.text = "0 / 0"
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .white
        label.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        label.textAlignment = .center
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        return label
    }()
    
    let deletePhotoButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "xmark")
        config.baseForegroundColor = .white
        let button = UIButton(configuration: config)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 18
        button.clipsToBounds = true
        return button
    }()

    let actionStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        return stack
    }()
    
    let takePhotoButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "촬영"
        config.image = UIImage(systemName: "camera")
        config.imagePadding = 8
        config.baseBackgroundColor = UIColor.systemBlue.withAlphaComponent(0.08)
        config.baseForegroundColor = .systemBlue
        config.cornerStyle = .large
        let button = UIButton(configuration: config)
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return button
    }()

    let galleryButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "앨범"
        config.image = UIImage(systemName: "photo.on.rectangle")
        config.imagePadding = 8
        config.baseBackgroundColor = UIColor.systemBlue.withAlphaComponent(0.08)
        config.baseForegroundColor = .systemBlue
        config.cornerStyle = .large
        let button = UIButton(configuration: config)
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return button
    }()

    let captionCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    let captionInputView = CaptionInputView(maxLength: RecordCaptionValidator.maxLength)

    let locationTitleTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "제목을 입력하세요"
        field.font = .systemFont(ofSize: 16)
        field.borderStyle = .roundedRect
        field.clearButtonMode = .whileEditing
        return field
    }()

    let locationField = LocationFieldView()

    private let chipsScrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        return scroll
    }()

    private let chipsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        return stack
    }()

    private let chipButtons: [UIButton] = (0..<5).map { _ in
        var config = UIButton.Configuration.filled()
        config.baseForegroundColor = .systemBlue
        config.baseBackgroundColor = UIColor.systemBlue.withAlphaComponent(0.08)
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 14, weight: .semibold)
            return outgoing
        }
        let button = UIButton(configuration: config)
        button.isHidden = true
        return button
    }

    let mapContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 18
        view.clipsToBounds = true
        return view
    }()
    
    let mapView: MKMapView = {
        let map = MKMapView()
        map.showsUserLocation = false
        map.pointOfInterestFilter = .includingAll
        return map
    }()

    let recordButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "기록 저장하기"
        config.image = UIImage(systemName: "square.and.pencil")
        config.imagePadding = 10
        config.baseBackgroundColor = .systemBlue
        config.baseForegroundColor = .white
        config.cornerStyle = .large
        let button = UIButton(configuration: config)
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return button
    }()

    let loadingOverlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        view.isHidden = true
        return view
    }()

    let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - Init

    init(mode: RecordViewMode) {
        self.mode = mode
        super.init(frame: .zero)
        setupUI()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private
    private func setupUI() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)

        [
            photoContainerView,
            captionCountLabel,
            captionInputView,
            locationTitleTextField,
            locationField,
            mapContainerView
        ].forEach { contentView.addSubview($0) }

        photoContainerView.addSubview(collectionView)
        photoContainerView.addSubview(photoEmptyLabel)
        photoContainerView.addSubview(pageBadgeLabel)

        mapContainerView.addSubview(mapView)

        var allViews: [UIView] = [
            scrollView,
            contentView,
            photoContainerView,
            collectionView,
            photoEmptyLabel,
            pageBadgeLabel,
            captionCountLabel,
            captionInputView,
            locationTitleTextField,
            locationField,
            mapContainerView,
            mapView
        ]

        switch mode {
        case .create:
            addSubview(recordButton)
            addSubview(loadingOverlayView)
            loadingOverlayView.addSubview(loadingIndicator)

            photoContainerView.addSubview(deletePhotoButton)
            contentView.addSubview(actionStack)
            contentView.addSubview(chipsScrollView)

            actionStack.addArrangedSubview(takePhotoButton)
            actionStack.addArrangedSubview(galleryButton)

            chipsScrollView.addSubview(chipsStackView)
            chipButtons.forEach { chipsStackView.addArrangedSubview($0) }

            allViews += [
                recordButton,
                loadingOverlayView,
                loadingIndicator,
                deletePhotoButton,
                actionStack,
                chipsScrollView,
                chipsStackView
            ] + chipButtons

        case .detail:
            locationField.isUserInteractionEnabled = false
            locationTitleTextField.isEnabled = false
        }

        allViews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        captionCountLabel.text = "0 / \(RecordCaptionValidator.maxLength)"
    }

    private func setupLayout() {
        // MARK: Common constraints
        var constraints = [
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            locationTitleTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            locationTitleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            locationTitleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            locationTitleTextField.heightAnchor.constraint(equalToConstant: 44),

            photoContainerView.topAnchor.constraint(equalTo: locationTitleTextField.bottomAnchor, constant: 16),
            photoContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            photoContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            photoContainerView.heightAnchor.constraint(equalToConstant: 240),

            collectionView.topAnchor.constraint(equalTo: photoContainerView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: photoContainerView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: photoContainerView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: photoContainerView.bottomAnchor),

            photoEmptyLabel.centerXAnchor.constraint(equalTo: photoContainerView.centerXAnchor),
            photoEmptyLabel.centerYAnchor.constraint(equalTo: photoContainerView.centerYAnchor),
            photoEmptyLabel.leadingAnchor.constraint(greaterThanOrEqualTo: photoContainerView.leadingAnchor, constant: 16),
            photoEmptyLabel.trailingAnchor.constraint(lessThanOrEqualTo: photoContainerView.trailingAnchor, constant: -16),

            pageBadgeLabel.trailingAnchor.constraint(equalTo: photoContainerView.trailingAnchor, constant: -12),
            pageBadgeLabel.bottomAnchor.constraint(equalTo: photoContainerView.bottomAnchor, constant: -12),
            pageBadgeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 64),
            pageBadgeLabel.heightAnchor.constraint(equalToConstant: 28),

            captionInputView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            captionInputView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            locationField.topAnchor.constraint(equalTo: captionInputView.bottomAnchor, constant: 24),
            locationField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            locationField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            mapContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mapContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mapContainerView.heightAnchor.constraint(equalToConstant: 220),
            mapContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),

            mapView.topAnchor.constraint(equalTo: mapContainerView.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: mapContainerView.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: mapContainerView.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: mapContainerView.bottomAnchor),

            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
        ]

        switch mode {
        case .create:
            constraints += [
                scrollView.bottomAnchor.constraint(equalTo: recordButton.topAnchor, constant: -12),

                deletePhotoButton.topAnchor.constraint(equalTo: photoContainerView.topAnchor, constant: 12),
                deletePhotoButton.trailingAnchor.constraint(equalTo: photoContainerView.trailingAnchor, constant: -12),

                actionStack.topAnchor.constraint(equalTo: photoContainerView.bottomAnchor, constant: 18),
                actionStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                actionStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

                captionCountLabel.topAnchor.constraint(equalTo: actionStack.bottomAnchor, constant: 8),
                captionCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

                captionInputView.topAnchor.constraint(equalTo: captionCountLabel.bottomAnchor, constant: 4),

                chipsScrollView.topAnchor.constraint(equalTo: locationField.bottomAnchor, constant: 12),
                chipsScrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                chipsScrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                chipsScrollView.heightAnchor.constraint(equalToConstant: 36),

                chipsStackView.topAnchor.constraint(equalTo: chipsScrollView.topAnchor),
                chipsStackView.leadingAnchor.constraint(equalTo: chipsScrollView.leadingAnchor),
                chipsStackView.trailingAnchor.constraint(equalTo: chipsScrollView.trailingAnchor),
                chipsStackView.bottomAnchor.constraint(equalTo: chipsScrollView.bottomAnchor),

                mapContainerView.topAnchor.constraint(equalTo: chipsScrollView.bottomAnchor, constant: 16),

                recordButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
                recordButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),
                recordButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16),

                loadingOverlayView.topAnchor.constraint(equalTo: topAnchor),
                loadingOverlayView.leadingAnchor.constraint(equalTo: leadingAnchor),
                loadingOverlayView.trailingAnchor.constraint(equalTo: trailingAnchor),
                loadingOverlayView.bottomAnchor.constraint(equalTo: bottomAnchor),

                loadingIndicator.centerXAnchor.constraint(equalTo: loadingOverlayView.centerXAnchor),
                loadingIndicator.centerYAnchor.constraint(equalTo: loadingOverlayView.centerYAnchor),
            ]

        case .detail:
            constraints += [
                scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),

                captionCountLabel.topAnchor.constraint(equalTo: photoContainerView.bottomAnchor, constant: 18),
                captionCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

                captionInputView.topAnchor.constraint(equalTo: captionCountLabel.bottomAnchor, constant: 4),

                mapContainerView.topAnchor.constraint(equalTo: locationField.bottomAnchor, constant: 16),
            ]
        }

        NSLayoutConstraint.activate(constraints)
    }

    // MARK: - Public
    func updateChips(_ suggestions: [SuggestedLocation]) {
        guard mode == .create else { return }
        for (index, button) in chipButtons.enumerated() {
            if index < suggestions.count {
                let suggestion = suggestions[index]
                button.isHidden = false
                button.setTitle(suggestion.title, for: .normal)
                button.tag = index
            } else {
                button.isHidden = true
                button.setTitle(nil, for: .normal)
                button.tag = index
            }
        }
        chipsScrollView.isHidden = suggestions.isEmpty
    }
}

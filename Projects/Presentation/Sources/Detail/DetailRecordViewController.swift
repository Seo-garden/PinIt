//
//  DetailRecordViewController.swift
//  Presentation
//
//  Created by 서정원 on 4/2/26.
//

import Domain
import MapKit
import RxCocoa
import RxRelay
import RxSwift
import UIKit

public final class DetailRecordViewController: BaseViewController<DetailRecordViewModel> {
    private let coordinator: DetailRecordCoordinator
    private let currentPageRelay = PublishRelay<Int>()
    private let deleteConfirmedRelay = PublishRelay<Void>()
    private let recordView = RecordView(mode: .detail)
    private var currentPhotos: [PhotoData] = []

    private let backButton = UIBarButtonItem(
        image: UIImage(systemName: "chevron.left"),
        style: .plain,
        target: nil,
        action: nil
    )

    private let deleteButton = UIBarButtonItem(
        image: UIImage(systemName: "trash"),
        style: .plain,
        target: nil,
        action: nil
    )

    public init(viewModel: DetailRecordViewModel, coordinator: DetailRecordCoordinator) {
        self.coordinator = coordinator
        super.init(viewModel: viewModel)
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        title = AppStrings.Detail.title
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let layout = recordView.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let size = CGSize(
                width: recordView.photoContainerView.bounds.width,
                height: recordView.photoContainerView.bounds.height
            )
            if layout.itemSize != size {
                layout.itemSize = size
                layout.invalidateLayout()
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup
    public override func setupUI() {
        view.addSubview(recordView)
        [recordView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        recordView.collectionView.dataSource = self
        recordView.collectionView.delegate = self
        recordView.collectionView.register(
            PhotoPreviewCell.self,
            forCellWithReuseIdentifier: PhotoPreviewCell.reuseIdentifier
        )

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        recordView.scrollView.addGestureRecognizer(tapGesture)

        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = deleteButton

        deleteButton.tintColor = .systemRed
    }

    public override func setupLayout() {
        NSLayoutConstraint.activate([
            recordView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            recordView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            recordView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            recordView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    public override func bind() {
        let input = DetailRecordViewModel.Input(
            captionChanged: recordView.captionInputView.textChanges().asSignal(onErrorJustReturn: ""),
            currentPageChanged: currentPageRelay.asSignal(onErrorSignalWith: .empty()),
            backTap: backButton.rx.tap.asSignal(),
            deleteTap: deleteConfirmedRelay.asSignal(onErrorSignalWith: .empty())
        )

        deleteButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.coordinator.showDeleteConfirmation(from: self) { [weak self] in
                    self?.deleteConfirmedRelay.accept(())
                }
            })
            .disposed(by: disposeBag)

        let output = viewModel.transform(input: input)

        output.state
            .drive(onNext: { [weak self] state in self?.apply(state: state) })
            .disposed(by: disposeBag)

        output.showAlert
            .emit(onNext: { [weak self] alert in
                guard let self else { return }
                self.coordinator.showAlert(from: self, title: alert.title, message: alert.message)
            })
            .disposed(by: disposeBag)

        output.saved
            .emit(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)

        output.deleted
            .emit(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)

        NotificationCenter.default.addObserver(
            self, selector: #selector(handleKeyboard(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleKeyboard(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }

    // MARK: - State

    private var previousState: DetailRecordViewModel.State?

    private func apply(state: DetailRecordViewModel.State) {
        let isFirstRender = previousState == nil
        let photoChanged = isFirstRender || previousState?.photo != state.photo
        let formChanged = isFirstRender || previousState?.form != state.form
        let locationChanged = isFirstRender || previousState?.location != state.location

        previousState = state
        currentPhotos = state.photo.photos

        if photoChanged {
            recordView.collectionView.reloadData()
            recordView.photoEmptyLabel.isHidden = state.hasPhotos
            recordView.pageBadgeLabel.isHidden = !state.hasPhotos
            recordView.pageBadgeLabel.text = state.pageBadgeText

            if state.photo.currentPage < recordView.collectionView.numberOfItems(inSection: 0) {
                let indexPath = IndexPath(item: state.photo.currentPage, section: 0)
                recordView.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            }
        }

        if formChanged {
            recordView.captionInputView.setText(state.form.caption)
            recordView.captionCountLabel.text = state.captionCountText
        }

        if locationChanged {
            recordView.locationField.configure(
                text: state.location.locationName,
                showsClear: false
            )

            recordView.mapView.removeAnnotations(recordView.mapView.annotations)
            if let coordinate = state.location.coordinate?.clLocationCoordinate2D {
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = state.location.locationName
                recordView.mapView.addAnnotation(annotation)
            }

            let region = MapRegionHelper.region(for: state.location.coordinate?.clLocationCoordinate2D)
            recordView.mapView.setRegion(region, animated: !isFirstRender)
        }
    }

    // MARK: - Actions

    @objc private func handleKeyboard(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let frameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = frameValue.cgRectValue
        let isShowing = notification.name == UIResponder.keyboardWillShowNotification
        let bottomInset = isShowing ? keyboardFrame.height - view.safeAreaInsets.bottom + 10 : 0
        recordView.scrollView.contentInset.bottom = bottomInset
        recordView.scrollView.verticalScrollIndicatorInsets.bottom = bottomInset
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - CollectionView

extension DetailRecordViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        currentPhotos.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotoPreviewCell.reuseIdentifier,
            for: indexPath
        ) as? PhotoPreviewCell else {
            return UICollectionViewCell()
        }
        if indexPath.item < currentPhotos.count,
           let image = UIImage(data: currentPhotos[indexPath.item].imageData) {
            cell.configure(image: image)
        }
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let images = currentPhotos.compactMap { UIImage(data: $0.imageData) }
        guard !images.isEmpty else { return }
        coordinator.presentPhotoDetail(from: self, images: images, initialPage: indexPath.item)
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / max(scrollView.bounds.width, 1))
        currentPageRelay.accept(page)
    }
}

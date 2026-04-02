//
//  CreateRecordViewController.swift
//  Presentation
//
//  Created by 서정원 on 3/11/26.
//

import Domain
import MapKit
import RxCocoa
import RxRelay
import RxSwift
import UIKit

public final class CreateRecordViewController: BaseViewController<CreateRecordViewModel> {
    private let coordinator: CreateRecordCoordinator
    private let addPhotosRelay = PublishRelay<[PhotoData]>()
    private let currentPageRelay = PublishRelay<Int>()
    private let selectSuggestedLocationRelay = PublishRelay<Int>()
    private let searchedLocationRelay = PublishRelay<(name: String, coordinate: Coordinate)>()
    private let recordView = RecordView(mode: .create)
    private var currentPhotos: [PhotoData] = []
    
    private let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: nil, action: nil)

    public init(viewModel: CreateRecordViewModel, coordinator: CreateRecordCoordinator) {
        self.coordinator = coordinator
        super.init(viewModel: viewModel)
    }

    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        title = AppStrings.Record.newMemoryTitle
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let layout = recordView.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let size = CGSize(width: recordView.photoContainerView.bounds.width, height: recordView.photoContainerView.bounds.height)
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
        recordView.collectionView.register(PhotoPreviewCell.self, forCellWithReuseIdentifier: PhotoPreviewCell.reuseIdentifier)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        recordView.scrollView.addGestureRecognizer(tapGesture)

        recordView.suggestionButtons.forEach {
            $0.addTarget(self, action: #selector(didTapSuggestionChip(_:)), for: .touchUpInside)
        }
        
        navigationItem.leftBarButtonItem = closeButton
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
        let input = CreateRecordViewModel.Input(
            takePhotoTap: recordView.takePhotoButton.rx.tap.asSignal(),
            galleryTap: recordView.galleryButton.rx.tap.asSignal(),
            addPhotos: addPhotosRelay.asSignal(onErrorSignalWith: .empty()),
            deleteCurrentPhoto: recordView.deletePhotoButton.rx.tap.asSignal(),
            captionChanged: recordView.captionInputView.textChanges().asSignal(onErrorJustReturn: ""),
            currentPageChanged: currentPageRelay.asSignal(onErrorSignalWith: .empty()),
            clearLocationTap: recordView.locationField.clear,
            selectSuggestedLocation: selectSuggestedLocationRelay.asSignal(onErrorSignalWith: .empty()),
            searchedLocation: searchedLocationRelay.asSignal(onErrorSignalWith: .empty()),
            recordTap: recordView.recordButton.rx.tap.asSignal()
        )
        
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in self?.dismiss(animated: true) })
            .disposed(by: disposeBag)

        recordView.locationField.tap
            .emit(onNext: { [weak self] in
                guard let self else { return }
                self.coordinator.pushLocationSearch(from: self) { [weak self] item in
                    guard let coordinate = Coordinate(latitude: item.latitude, longitude: item.longitude) else { return }
                    self?.searchedLocationRelay.accept((name: item.name, coordinate: coordinate))
                }
            })
            .disposed(by: disposeBag)

        let output = viewModel.transform(input: input)

        output.state
            .drive(onNext: { [weak self] state in self?.apply(state: state) })
            .disposed(by: disposeBag)

        output.requestCamera
            .emit(onNext: { [weak self] in
                guard let self else { return }
                self.coordinator.presentCamera(
                    from: self,
                    completion: { [weak self] result in self?.handlePhotoResult(result) },
                    onPermissionDenied: { [weak self] source in self?.handlePermissionDenied(source) }
                )
            })
            .disposed(by: disposeBag)

        output.requestGallery
            .emit(onNext: { [weak self] maxCount in
                guard let self, maxCount > 0 else { return }
                self.coordinator.presentGallery(
                    from: self,
                    maxAdditionalCount: maxCount,
                    completion: { [weak self] result in self?.handlePhotoResult(result) },
                    onPermissionDenied: { [weak self] source in self?.handlePermissionDenied(source) }
                )
            })
            .disposed(by: disposeBag)

        output.showAlert
            .emit(onNext: { [weak self] alert in
                guard let self else { return }
                self.coordinator.showAlert(from: self, title: alert.title, message: alert.message)
            })
            .disposed(by: disposeBag)

        output.finish
            .emit(onNext: { [weak self] _ in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)

        output.photoDeleted
            .emit(onNext: { [weak self] index in
                guard let self else { return }
                let indexPath = IndexPath(item: index, section: 0)
                self.recordView.collectionView.performBatchUpdates({
                    self.recordView.collectionView.deleteItems(at: [indexPath])
                }) { [weak self] _ in
                    guard let self else { return }
                    // 삭제 애니메이션 완료 후, 올바른 페이지로 스크롤 + 페이지 동기화
                    let targetPage = max(0, min(index, self.currentPhotos.count - 1))
                    if targetPage < self.recordView.collectionView.numberOfItems(inSection: 0) {
                        let ip = IndexPath(item: targetPage, section: 0)
                        self.recordView.collectionView.scrollToItem(at: ip, at: .centeredHorizontally, animated: true)
                    }
                    self.currentPageRelay.accept(targetPage)
                }
            })
            .disposed(by: disposeBag)

        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private var previousState: CreateRecordViewModel.State?

    private func apply(state: CreateRecordViewModel.State) {
        let isFirstRender = previousState == nil
        let photoChanged = isFirstRender || previousState?.photo != state.photo
        let formChanged = isFirstRender || previousState?.form != state.form
        let locationChanged = isFirstRender || previousState?.location != state.location
        let oldPhotosCount = previousState?.photo.photos.count ?? 0

        previousState = state
        currentPhotos = state.photo.photos

        if photoChanged {
            recordView.photoEmptyLabel.isHidden = state.hasPhotos
            recordView.pageBadgeLabel.isHidden = !state.hasPhotos
            recordView.deletePhotoButton.isHidden = !state.hasPhotos
            recordView.pageBadgeLabel.text = state.pageBadgeText

            let isInsertion = state.photo.photos.count > oldPhotosCount
            let isDeletion = state.photo.photos.count < oldPhotosCount
            if isInsertion {
                recordView.collectionView.reloadData()
            }

            // 삭제 시에는 performBatchUpdates completion에서 스크롤 처리하므로 여기서 건너뜀
            if !isDeletion,
               state.photo.currentPage < recordView.collectionView.numberOfItems(inSection: 0) {
                let indexPath = IndexPath(item: state.photo.currentPage, section: 0)
                recordView.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }
        }

        if formChanged {
            recordView.captionInputView.setText(state.form.caption)
            recordView.captionCountLabel.text = state.captionCountText
        }

        if locationChanged {
            recordView.locationField.configure(
                text: state.location.locationName,
                showsClear: !(state.location.locationName ?? "").isEmpty
            )
            recordView.updateChips(state.location.suggestions)

            recordView.mapView.removeAnnotations(recordView.mapView.annotations)
            if let coordinate = state.location.coordinate?.clLocationCoordinate2D {
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = state.location.locationName
                recordView.mapView.addAnnotation(annotation)
            }

            let shouldAnimate = state.location.coordinate != nil
            let region = MapRegionHelper.region(for: state.location.coordinate?.clLocationCoordinate2D)
            recordView.mapView.setRegion(region, animated: shouldAnimate)
        }

        if photoChanged || formChanged {
            recordView.recordButton.isEnabled = state.isRecordEnabled
            recordView.recordButton.alpha = state.isRecordEnabled ? 1.0 : 0.5
        }
    }

    @objc private func didTapSuggestionChip(_ sender: UIButton) {
        selectSuggestedLocationRelay.accept(sender.tag)
    }

    @objc private func handleKeyboard(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let frameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = frameValue.cgRectValue
        let isShowing = notification.name == UIResponder.keyboardWillShowNotification
        let bottomInset = isShowing ? keyboardFrame.height - view.safeAreaInsets.bottom + 10 : 0
        recordView.scrollView.contentInset.bottom = bottomInset + recordView.recordButton.bounds.height + 12
        recordView.scrollView.verticalScrollIndicatorInsets.bottom = bottomInset
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Helpers
    private func handlePhotoResult(_ result: Result<[PhotoData], PhotoError>) {
        switch result {
        case .success(let photos):
            addPhotosRelay.accept(photos)
        case .failure(let error):
            switch error {
            case .unavailable:
                coordinator.showAlert(from: self, title: AppStrings.Record.cameraUnavailableMessage, message: "")
            case .accessDenied:
                coordinator.showAlert(from: self, title: AppStrings.Record.cameraDeniedMessage, message: error.localizedDescription)
            case .loadFailed:
                coordinator.showAlert(from: self, title: AppStrings.Record.photoErrorMessage, message: error.localizedDescription)
            }
        }
    }

    private func handlePermissionDenied(_ source: PermissionSource) {
        let isCamera = source == .camera
        let title = isCamera ? AppStrings.Record.cameraDeniedTitle : AppStrings.Record.galleryDeniedTitle
        let message = isCamera ? AppStrings.Record.cameraDeniedMessage : AppStrings.Record.galleryDeniedMessage
        showSettingsAlert(title: title, message: message)
    }

    private func showSettingsAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: AppStrings.Common.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: AppStrings.Common.openSettings, style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        })
        present(alert, animated: true)
    }
}

// MARK: - CollectionView
extension CreateRecordViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        currentPhotos.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoPreviewCell.reuseIdentifier, for: indexPath) as? PhotoPreviewCell else {
            return UICollectionViewCell()
        }
        if indexPath.item < currentPhotos.count,
           let image = UIImage(data: currentPhotos[indexPath.item].imageData) {
            cell.configure(image: image)
        }
        return cell
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / max(scrollView.bounds.width, 1))
        currentPageRelay.accept(page)
    }
}

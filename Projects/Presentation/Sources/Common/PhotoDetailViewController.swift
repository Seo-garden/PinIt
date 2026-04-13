//
//  PhotoDetailViewController.swift
//  Presentation
//
//  Created by 서정원 on 4/13/26.
//

import UIKit

final class PhotoDetailViewController: UIViewController {
    private let images: [UIImage]
    private let initialPage: Int

    // MARK: - UI

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.isPagingEnabled = true
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = .black
        return view
    }()

    private let closeButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "xmark")
        config.baseForegroundColor = .white
        let button = UIButton(configuration: config)
        return button
    }()

    private let pageBadgeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .white
        label.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        label.textAlignment = .center
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        return label
    }()

    // MARK: - Init

    init(images: [UIImage], initialPage: Int) {
        self.images = images
        self.initialPage = initialPage
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        updatePageBadge(page: initialPage)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let size = view.bounds.size
            if layout.itemSize != size {
                layout.itemSize = size
                layout.invalidateLayout()
            }
        }

        if initialPage > 0 {
            let offset = CGFloat(initialPage) * collectionView.bounds.width
            if collectionView.contentOffset.x == 0, offset > 0 {
                collectionView.setContentOffset(CGPoint(x: offset, y: 0), animated: false)
            }
        }
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .black

        view.addSubview(collectionView)
        view.addSubview(closeButton)
        view.addSubview(pageBadgeLabel)

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            PhotoDetailCell.self,
            forCellWithReuseIdentifier: PhotoDetailCell.reuseIdentifier
        )

        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
    }

    private func setupLayout() {
        [collectionView, closeButton, pageBadgeLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),

            pageBadgeLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            pageBadgeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageBadgeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 64),
            pageBadgeLabel.heightAnchor.constraint(equalToConstant: 28),
        ])
    }

    // MARK: - Actions

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    private func updatePageBadge(page: Int) {
        pageBadgeLabel.text = "\(page + 1) / \(images.count)"
        pageBadgeLabel.isHidden = images.count <= 1
    }
}

// MARK: - UICollectionViewDataSource & Delegate

extension PhotoDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotoDetailCell.reuseIdentifier,
            for: indexPath
        ) as? PhotoDetailCell else {
            return UICollectionViewCell()
        }
        cell.configure(image: images[indexPath.item])
        return cell
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / max(scrollView.bounds.width, 1))
        updatePageBadge(page: page)
    }
}

//
//  MapBottomSheetView.swift
//  Presentation
//
//  Created by 서정원 on 4/15/26.
//

import Domain
import RxCocoa
import RxRelay
import RxSwift
import UIKit

public final class MapBottomSheetView: UIView {
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.register(
            MapBottomSheetCell.self,
            forCellWithReuseIdentifier: MapBottomSheetCell.reuseIdentifier
        )
        return collectionView
    }()

    private let pageControl: UIPageControl = {
        let control = UIPageControl()
        control.currentPageIndicatorTintColor = .label
        control.pageIndicatorTintColor = .quaternaryLabel
        control.hidesForSinglePage = true
        control.isUserInteractionEnabled = false
        return control
    }()

    private var records: [Record] = []

    public let selectedRecord = PublishRelay<Record>()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout,
           layout.itemSize != collectionView.bounds.size,
           collectionView.bounds.size.width > 0 {
            layout.itemSize = collectionView.bounds.size
            layout.invalidateLayout()
        }
    }

    public func configure(records: [Record]) {
        self.records = records
        pageControl.numberOfPages = records.count
        pageControl.currentPage = 0
        collectionView.reloadData()
        collectionView.setContentOffset(.zero, animated: false)
    }

    private func setupUI() {
        backgroundColor = .systemGray6
        layer.cornerRadius = 20
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: -2)
        layer.shadowRadius = 8

        addSubview(collectionView)
        addSubview(pageControl)

        [collectionView, pageControl].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -4),

            pageControl.centerXAnchor.constraint(equalTo: centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -4),
            pageControl.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
}

// MARK: - UICollectionViewDataSource
extension MapBottomSheetView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        records.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MapBottomSheetCell.reuseIdentifier,
            for: indexPath
        ) as! MapBottomSheetCell
        cell.configure(with: records[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension MapBottomSheetView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard records.indices.contains(indexPath.item) else { return }
        selectedRecord.accept(records[indexPath.item])
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.bounds.width
        guard width > 0 else { return }
        let page = Int((scrollView.contentOffset.x + width / 2) / width)
        if page != pageControl.currentPage {
            pageControl.currentPage = page
        }
    }
}

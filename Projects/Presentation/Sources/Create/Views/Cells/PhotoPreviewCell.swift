//
//  PhotoPreviewCell.swift
//  Presentation
//
//  Created by 서정원 on 3/12/26.
//

import UIKit

final class PhotoPreviewCell: UICollectionViewCell {
    static let reuseIdentifier = "PhotoPreviewCell"

    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 18
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }
    
    private func setupUI() {
        contentView.addSubview(imageView)
        [imageView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(image: UIImage) {
        imageView.image = image
    }
}

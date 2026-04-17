//
//  FeedCell.swift
//  Presentation
//
//  Created by 서정원 on 4/17/26.
//

import Domain
import UIKit

public final class FeedCell: UITableViewCell {
    static let reuseIdentifier = "FeedCell"

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        return formatter
    }()

    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        imageView.layer.cornerRadius = 8
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()

    private let locationNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .tertiaryLabel
        label.numberOfLines = 1
        return label
    }()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupLayout()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
        titleLabel.text = nil
        locationNameLabel.text = nil
        dateLabel.text = nil
    }

    public func configure(with record: Record) {
        if let data = record.photoDataList.first?.imageData {
            thumbnailImageView.image = UIImage(data: data)
        }
        titleLabel.text = record.locationTitle
        locationNameLabel.text = record.locationName
        dateLabel.text = Self.dateFormatter.string(from: record.createdAt)
    }

    private func setupUI() {
        accessoryType = .disclosureIndicator
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(locationNameLabel)
        contentView.addSubview(dateLabel)

        [thumbnailImageView, titleLabel, locationNameLabel, dateLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            thumbnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            thumbnailImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 64),
            thumbnailImageView.heightAnchor.constraint(equalTo: thumbnailImageView.widthAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            titleLabel.topAnchor.constraint(equalTo: thumbnailImageView.topAnchor, constant: 2),

            locationNameLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            locationNameLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            locationNameLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),

            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            dateLabel.topAnchor.constraint(equalTo: locationNameLabel.bottomAnchor, constant: 6)
        ])
    }
}

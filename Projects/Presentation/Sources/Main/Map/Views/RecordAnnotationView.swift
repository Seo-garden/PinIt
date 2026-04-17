//
//  RecordAnnotationView.swift
//  Presentation
//
//  Created by 서정원 on 4/13/26.
//

import MapKit
import UIKit

public final class RecordAnnotationView: MKAnnotationView {
    static let reuseIdentifier = "RecordAnnotationView"

    private let imageSize: CGFloat = 52
    private let padding: CGFloat = 4
    private let cornerRadius: CGFloat = 10
    private let tailHeight: CGFloat = 8

    private var bubbleSize: CGSize {
        let side = imageSize + padding * 2
        return CGSize(width: side, height: side + tailHeight)
    }

    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        return imageView
    }()

    private let badgeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = .systemBlue
        label.clipsToBounds = true
        return label
    }()

    private let bubbleView = UIView()

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
        badgeLabel.isHidden = true
    }

    public func configure(with annotation: RecordAnnotation) {
        if let data = annotation.thumbnailData {
            thumbnailImageView.image = UIImage(data: data)
        }

        let count = annotation.recordCount
        if count > 1 {
            badgeLabel.text = "\(count)"
            badgeLabel.isHidden = false
        } else {
            badgeLabel.isHidden = true
        }
    }

    private func setupUI() {
        let totalSize = bubbleSize
        frame = CGRect(origin: .zero, size: totalSize)
        centerOffset = CGPoint(x: 0, y: -totalSize.height / 2)
        backgroundColor = .clear

        bubbleView.frame = CGRect(origin: .zero, size: totalSize)
        bubbleView.backgroundColor = .clear
        addSubview(bubbleView)

        let bubbleBodyHeight = totalSize.height - tailHeight
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bubblePath(
            rect: CGRect(x: 0, y: 0, width: totalSize.width, height: bubbleBodyHeight),
            cornerRadius: cornerRadius,
            tailHeight: tailHeight
        )
        shapeLayer.fillColor = UIColor.white.cgColor
        shapeLayer.shadowColor = UIColor.black.cgColor
        shapeLayer.shadowOpacity = 0.2
        shapeLayer.shadowOffset = CGSize(width: 0, height: 2)
        shapeLayer.shadowRadius = 4
        bubbleView.layer.insertSublayer(shapeLayer, at: 0)

        thumbnailImageView.frame = CGRect(
            x: padding,
            y: padding,
            width: imageSize,
            height: imageSize
        )
        thumbnailImageView.layer.cornerRadius = cornerRadius - 2
        bubbleView.addSubview(thumbnailImageView)

        let badgeSize: CGFloat = 20
        badgeLabel.frame = CGRect(
            x: totalSize.width - badgeSize / 2,
            y: -badgeSize / 2,
            width: badgeSize,
            height: badgeSize
        )
        badgeLabel.layer.cornerRadius = badgeSize / 2
        badgeLabel.isHidden = true
        bubbleView.addSubview(badgeLabel)
    }

    private func bubblePath(rect: CGRect, cornerRadius: CGFloat, tailHeight: CGFloat) -> CGPath {
        let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)

        let tailWidth: CGFloat = 12
        let bottomCenter = CGPoint(x: rect.midX, y: rect.maxY)

        let tailPath = UIBezierPath()
        tailPath.move(to: CGPoint(x: bottomCenter.x - tailWidth / 2, y: bottomCenter.y))
        tailPath.addLine(to: CGPoint(x: bottomCenter.x, y: bottomCenter.y + tailHeight))
        tailPath.addLine(to: CGPoint(x: bottomCenter.x + tailWidth / 2, y: bottomCenter.y))
        tailPath.close()

        path.append(tailPath)
        return path.cgPath
    }
}

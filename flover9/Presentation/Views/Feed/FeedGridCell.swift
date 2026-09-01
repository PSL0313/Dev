//
//  FeedGridCell.swift
//  flover9
//
//  Created by 박선린 on 8/27/26.
//
import UIKit
import Kingfisher

final class FeedGridCell: UICollectionViewCell {
    static let reuseIdentifier = "FeedGridCell"

    private let imageView = UIImageView()

    private let hasMultipleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo.stack")
        imageView.tintColor = .systemGray
        return imageView
    }()

    private let dimView = UIView()
    private let lockImageView = UIImageView()

//    private let progressView: UIProgressView = {
//        let view = UIProgressView()
//        view.tintColor = .systemBlue
//        view.progress = 0
//        return view
//    }()

    private let progressLayer: CAShapeLayer = {
        let circularPath = UIBezierPath(
            arcCenter: CGPoint(x: 50, y: 50),
            radius: 40,
            startAngle: -.pi / 2,
            endAngle: .pi * 2,
            clockwise: true
        )
        let progressLayer = CAShapeLayer()
        progressLayer.path = circularPath.cgPath
        progressLayer.strokeEnd = 0
        progressLayer.strokeColor = UIColor.systemBlue.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = 8
        return progressLayer
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        configureStyle()
        configureLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
        hasMultipleImageView.isHidden = true
    }

    func configure(with feed: FeedEntity) {
        let isFromm = feed.source.lowercased() == "fromm"
        let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: .now) ?? .now
        let isLocked = isFromm && feed.captureDate >= oneYearAgo
        dimView.isHidden = !isLocked
        lockImageView.isHidden = !isLocked
        hasMultipleImageView.isHidden = feed.contentCount <= 1

        if let url = feed.thumbnailURL {

            let processor = DownsamplingImageProcessor(size: downsamplingSize())

            let processorForFrommImage = DownsamplingImageProcessor(size: downsamplingSize())
            |> BlurImageProcessor(blurRadius: 5)

            let scale = contentView.window?.windowScene?.screen.scale ?? 0.5

            imageView.kf.setImage(
                with: url,
                options: [
                    .processor(isFromm ? processorForFrommImage : processor),
                    .scaleFactor(scale),
                    .transition(.fade(0.15))
                ])

        } else {
            imageView.image = nil
        }

        self.imageView.backgroundColor = .systemBackground
    }

    private func downsamplingSize() -> CGSize {
        let size = CGSize(width: contentView.bounds.size.width * 1.5, height: contentView.bounds.size.height * 1.5)

        return size
    }

    private func configureHierarchy() {
        contentView.addSubview(imageView)
        contentView.addSubview(dimView)
        contentView.addSubview(lockImageView)
        contentView.addSubview(hasMultipleImageView)
    }

    private func configureStyle() {
        clipsToBounds = true

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemBackground

        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.22)
        dimView.isHidden = true

        lockImageView.image = UIImage(systemName: "lock.fill")
        lockImageView.tintColor = .white
        lockImageView.isHidden = true
    }

    private func configureLayout() {
        imageView.frame = contentView.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        dimView.frame = contentView.bounds
        dimView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        lockImageView.translatesAutoresizingMaskIntoConstraints = false
        hasMultipleImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            lockImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            lockImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            lockImageView.widthAnchor.constraint(equalToConstant: 20),
            lockImageView.heightAnchor.constraint(equalToConstant: 25),

            hasMultipleImageView.widthAnchor.constraint(equalToConstant: 20),
            hasMultipleImageView.heightAnchor.constraint(equalToConstant: 20),
            hasMultipleImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            hasMultipleImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])
    }
}

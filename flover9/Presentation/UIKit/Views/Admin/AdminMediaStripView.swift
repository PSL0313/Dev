//
//  AdminMediaStripView.swift
//  flover9
//
//  Created by 박선린 on 9/24/26.
//

import UIKit
import SnapKit
import Kingfisher

// MARK: - X는 삭제 예약만 변경하며 저장 전까지 원본은 유지
final class AdminMediaStripView: UIView {
    var onPreview: ((Int) -> Void)?
    var onToggleRemoval: ((UUID) -> Void)?
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        stackView.axis = .horizontal
        stackView.spacing = 12
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
        stackView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.height.equalTo(scrollView.frameLayoutGuide)
        }
        snp.makeConstraints { $0.height.equalTo(178) }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(items: [FeedImageEntity], removedIDs: Set<UUID>) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (index, item) in items.enumerated() {
            let card = UIView()
            card.backgroundColor = .tertiarySystemFill
            card.layer.cornerRadius = 14
            card.clipsToBounds = true
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            card.addSubview(imageView)
            imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
            if item.contentType.isVideo {
                imageView.image = UIImage(systemName: "play.rectangle.fill")
                imageView.contentMode = .scaleAspectFit
                imageView.tintColor = .secondaryLabel
            } else if item.imageURL.isFileURL {
                imageView.kf.setImage(with: .provider(LocalFileImageDataProvider(fileURL: item.imageURL)))
            } else {
                imageView.kf.setImage(with: item.imageURL, options: [.processor(DownsamplingImageProcessor(size: CGSize(width: 280, height: 356)))])
            }
            let preview = UIButton(type: .custom)
            preview.accessibilityLabel = "\(index + 1)번째 미디어 크게 보기"
            preview.addAction(UIAction { [weak self] _ in self?.onPreview?(index) }, for: .touchUpInside)
            card.addSubview(preview)
            preview.snp.makeConstraints { $0.edges.equalToSuperview() }

            let removed = removedIDs.contains(item.id)
            imageView.alpha = removed ? 0.25 : 1
            let remove = UIButton(type: .system)
            remove.setImage(UIImage(systemName: removed ? "arrow.uturn.backward.circle.fill" : "xmark.circle.fill"), for: .normal)
            remove.setPreferredSymbolConfiguration(.init(pointSize: 26, weight: .semibold), forImageIn: .normal)
            remove.tintColor = .white
            remove.backgroundColor = UIColor.black.withAlphaComponent(0.55)
            remove.layer.cornerRadius = 22
            remove.accessibilityLabel = removed ? "삭제 취소" : "\(index + 1)번째 미디어 삭제 예약"
            remove.addAction(UIAction { [weak self] _ in self?.onToggleRemoval?(item.id) }, for: .touchUpInside)
            card.addSubview(remove)
            remove.snp.makeConstraints {
                $0.top.trailing.equalToSuperview().inset(6)
                $0.size.equalTo(44)
            }
            if removed {
                let label = AdminStyle.label("저장 시 삭제", style: .caption1, color: .label)
                label.textAlignment = .center
                label.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.92)
                label.layer.cornerRadius = 8
                label.clipsToBounds = true
                card.addSubview(label)
                label.snp.makeConstraints {
                    $0.center.equalToSuperview()
                    $0.width.equalTo(116)
                    $0.height.greaterThanOrEqualTo(32)
                }
                label.isUserInteractionEnabled = false
            }
            stackView.addArrangedSubview(card)
            card.snp.makeConstraints { $0.width.equalTo(140) }
        }
    }
}

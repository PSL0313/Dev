//
//  WallpaperDetailHeader.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Kingfisher
import SnapKit
import UIKit

// 시리즈 대표 이미지·제작자 사진·설명과 그리드 전환 버튼을 표시하는 재사용 뷰입니다.
final class WallpaperDetailHeader: UICollectionReusableView {
    private let image = UIImageView(), titleLabel = UILabel(), creator = UILabel(), summary = UILabel(),
        category = UILabel(), countLabel = UILabel()
    private let creatorImage = UIImageView()
    private let toggle = UISegmentedControl(items: [
        UIImage(systemName: "square.grid.3x3.fill")!, UIImage(systemName: "rectangle.grid.1x2.fill")!,
    ])
    var onLayout: ((Bool) -> Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        addSubview(image)
        image.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(image.snp.width).multipliedBy(WallpaperLayout.heightToWidth)
        }
        let shade = WallpaperGradientView(colors: [.clear, .black])
        addSubview(shade)
        shade.snp.makeConstraints { $0.edges.equalTo(image) }
        titleLabel.font = .systemFont(ofSize: 27, weight: .bold)
        titleLabel.numberOfLines = 2
        titleLabel.textColor = .white
        creator.font = .systemFont(ofSize: 13)
        creator.textColor = .white
        summary.font = .systemFont(ofSize: 14)
        summary.textColor = WallpaperStyle.secondary
        summary.numberOfLines = 0
        category.font = .systemFont(ofSize: 12, weight: .medium)
        category.textColor = .white
        countLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        countLabel.textColor = .white
        [titleLabel, creatorImage, creator, summary, category, countLabel, toggle].forEach(addSubview)
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(18)
            $0.bottom.equalTo(image.snp.bottom).offset(-36)
        }
        creatorImage.contentMode = .scaleAspectFill
        creatorImage.clipsToBounds = true
        creatorImage.layer.cornerRadius = 10
        creatorImage.tintColor = WallpaperStyle.secondary
        creatorImage.isAccessibilityElement = false
        creatorImage.snp.makeConstraints {
            $0.leading.equalTo(titleLabel)
            $0.top.equalTo(titleLabel.snp.bottom).offset(6)
            $0.width.height.equalTo(20)
        }
        creator.snp.makeConstraints {
            $0.leading.equalTo(creatorImage.snp.trailing).offset(6)
            $0.centerY.equalTo(creatorImage)
            $0.trailing.lessThanOrEqualToSuperview().inset(18)
        }
        summary.snp.makeConstraints {
            $0.leading.trailing.equalTo(titleLabel)
            $0.top.equalTo(creatorImage.snp.bottom).offset(14)
        }
        category.snp.makeConstraints {
            $0.leading.equalTo(titleLabel)
            $0.top.equalTo(summary.snp.bottom).offset(12)
        }
        countLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel)
            $0.bottom.equalToSuperview().inset(8)
        }
        toggle.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalTo(countLabel)
            $0.width.equalTo(78)
            $0.height.equalTo(30)
        }
        toggle.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                onLayout?(toggle.selectedSegmentIndex == 0)
            }, for: .valueChanged)
        toggle.accessibilityLabel = "배경화면 그리드 크기"
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    func configure(_ series: WallpaperSeriesEntity, count: Int, compact: Bool) {
        WallpaperStyle.image(image, url: series.coverURL)
        titleLabel.text = series.title
        creator.text = "by. \(series.creatorName)"
        creatorImage.kf.setImage(
            with: series.creatorProfileImageURL,
            placeholder: UIImage(systemName: "person.crop.circle.fill"))
        summary.text = series.description
        category.text = "#\(series.category.title)"
        countLabel.text = "배경화면 \(count)"
        toggle.selectedSegmentIndex = compact ? 0 : 1
    }
}

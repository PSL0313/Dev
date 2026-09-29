//
//  WallpaperCardCell.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Kingfisher
import SnapKit
import UIKit

// 시리즈 커버 또는 개별 배경화면 이미지와 설명을 표시하는 재사용 뷰입니다.
final class WallpaperCardCell: UICollectionViewCell {
    static let reuseID = "WallpaperCard"
    
    let imageView = UIImageView()
    
    private let shade = WallpaperGradientView(colors: [.clear, .black.withAlphaComponent(0.8)])
    
    private let titleLabel = UILabel(), subtitle = UILabel(), countLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView.addSubview(shade)
        shade.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.65)
        }
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
        subtitle.font = .systemFont(ofSize: 11)
        subtitle.textColor = .white.withAlphaComponent(0.8)
        countLabel.font = .systemFont(ofSize: 11)
        countLabel.textColor = .white
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitle)
        contentView.addSubview(countLabel)
        subtitle.snp.makeConstraints {
            $0.leading.bottom.equalToSuperview().inset(12)
            $0.trailing.lessThanOrEqualTo(countLabel.snp.leading).offset(-4)
        }
        countLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(12)
            $0.centerY.equalTo(subtitle)
        }
        countLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.bottom.equalTo(subtitle.snp.top).offset(-5)
        }
        isAccessibilityElement = true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
    }
    
    func configure(series: WallpaperSeriesEntity) {
        WallpaperStyle.image(imageView, url: series.coverURL)
        shade.isHidden = false
        titleLabel.isHidden = false
        subtitle.isHidden = false
        countLabel.isHidden = false
        titleLabel.text = series.title
        subtitle.text = "by. \(series.creatorName)"
        countLabel.text = "▧ \(series.wallpaperCount)"
        accessibilityLabel = "\(series.title), \(series.creatorName), 배경화면 \(series.wallpaperCount)개"
    }
    
    
    func configure(wallpaper: WallpaperEntity, caption: Bool = false, useOriginal: Bool = false) {
        WallpaperStyle.image(imageView, url: useOriginal ? wallpaper.originalURL : wallpaper.mockupURL)
        shade.isHidden = !caption
        titleLabel.isHidden = !caption
        subtitle.isHidden = !caption
        countLabel.isHidden = true
        titleLabel.text = wallpaper.displayLabel
        subtitle.text = "by. \(wallpaper.creatorName)"
        accessibilityLabel = wallpaper.displayLabel
    }
}

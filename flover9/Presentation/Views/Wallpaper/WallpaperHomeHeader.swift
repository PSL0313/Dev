//
//  WallpaperHomeHeader.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Kingfisher
import SnapKit
import UIKit

// 홈의 배경 히어로·소개 문구·카테고리와 추천 섹션 제목을 표시하는 재사용 뷰입니다.
final class WallpaperHomeHeader: UICollectionReusableView {
    private let image = UIImageView()
    let categories = WallpaperCategoryControl()
    var onMore: (() -> Void)?
    let section = WallpaperSectionHeader()
    override init(frame: CGRect) {
        super.init(frame: frame)
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        addSubview(image)
        image.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(image.snp.width).multipliedBy(WallpaperLayout.heightToWidth)
        }
        let shade = WallpaperGradientView(colors: [.black.withAlphaComponent(0.15), .clear, .black])
        addSubview(shade)
        shade.snp.makeConstraints { $0.edges.equalTo(image) }
        let heading = UILabel()
        heading.text = "Wallpaper"
        heading.font = UIFont(name: "Georgia-Bold", size: 36) ?? .systemFont(ofSize: 36, weight: .bold)
        heading.textColor = .white
        let caption = UILabel()
        caption.text = "좋아하는 순간을\n당신의 화면에."
        caption.numberOfLines = 2
        caption.font = .systemFont(ofSize: 16)
        caption.textColor = .white.withAlphaComponent(0.85)
        addSubview(heading)
        addSubview(caption)
        addSubview(categories)
        addSubview(section)
        heading.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(24)
            $0.top.equalToSuperview().offset(136)
        }
        caption.snp.makeConstraints {
            $0.leading.equalTo(heading)
            $0.top.equalTo(heading.snp.bottom).offset(12)
        }
        categories.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(18)
            $0.bottom.equalTo(section.snp.top).offset(-12)
            $0.height.equalTo(38)
        }
        section.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(44)
        }
        section.titleLabel.text = "추천 시리즈"
        section.onMore = { [weak self] in self?.onMore?() }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    func configure(series: WallpaperSeriesEntity?, category: WallpaperCategory?, featuredEmpty: Bool) {
        WallpaperStyle.image(image, url: series?.coverURL)
        categories.select(category)
        section.titleLabel.text = featuredEmpty ? "새로운 시리즈" : "추천 시리즈"
    }
}

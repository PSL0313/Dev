//
//  WallpaperEntryCell.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import SnapKit
import UIKit

// 메인 홈에서 Wallpaper로 진입하는 배너을 표시하는 재사용 뷰입니다.
final class WallpaperEntryCell: UICollectionViewCell {
    private let image = UIImageView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 18
        contentView.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        contentView.addSubview(image)
        image.snp.makeConstraints { $0.edges.equalToSuperview() }
        let shade = WallpaperGradientView(colors: [
            UIColor(red: 0.24, green: 0.15, blue: 0.29, alpha: 0.9), .black.withAlphaComponent(0.3),
        ])
        contentView.addSubview(shade)
        shade.snp.makeConstraints { $0.edges.equalToSuperview() }
        let title = UILabel()
        title.text = "Wallpaper"
        title.font = .systemFont(ofSize: 25, weight: .bold)
        title.textColor = .white
        let subtitle = UILabel()
        subtitle.text = "특별한 순간을\n화면에 담아보세요."
        subtitle.font = .systemFont(ofSize: 14)
        subtitle.numberOfLines = 2
        subtitle.textColor = .white
        let stack = UIStackView(arrangedSubviews: [title, subtitle])
        stack.axis = .vertical
        stack.spacing = 5
        contentView.addSubview(stack)
        stack.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualToSuperview().inset(55)
        }
        let arrow = UIImageView(image: UIImage(systemName: "chevron.right.circle.fill"))
        arrow.tintColor = .white.withAlphaComponent(0.8)
        contentView.addSubview(arrow)
        arrow.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(18)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(28)
        }
        isAccessibilityElement = true
        accessibilityLabel = "Wallpaper, 배경화면 둘러보기"
        accessibilityTraits = .button
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    func configure(url: URL?) { WallpaperStyle.image(image, url: url) }
}

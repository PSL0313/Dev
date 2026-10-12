//
//  WallpaperCategoryControl.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Kingfisher
import SnapKit
import UIKit

// 전체·일반·캘린더·시계 카테고리 선택 버튼을 표시하는 재사용 뷰입니다.
final class WallpaperCategoryControl: UIStackView {
    var onSelect: ((WallpaperCategory?) -> Void)?
    private var buttons: [UIButton] = []
    private let categories: [WallpaperCategory?] = [nil] + WallpaperCategory.allCases.map(Optional.some)
    override init(frame: CGRect) {
        super.init(frame: frame)
        axis = .horizontal
        distribution = .fillEqually
        spacing = 6
        for (index, category) in categories.enumerated() {
            let button = UIButton(type: .system)
            button.tag = index
            button.setTitle(category?.title ?? "전체", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
            button.layer.cornerRadius = 18
            button.addAction(
                UIAction { [weak self] _ in
                    self?.select(category)
                    self?.onSelect?(category)
                }, for: .touchUpInside)
            addArrangedSubview(button)
            buttons.append(button)
        }
        select(nil)
    }
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    func select(_ category: WallpaperCategory?) {
        for (index, button) in buttons.enumerated() {
            let selected = categories[index] == category
            button.backgroundColor = selected ? .white : UIColor(white: 0.2, alpha: 0.7)
            button.setTitleColor(selected ? .black : UIColor(white: 0.85, alpha: 1), for: .normal)
            button.accessibilityTraits = selected ? [.button, .selected] : .button
        }
    }
}

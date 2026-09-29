//
//  WallpaperGradientView.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Kingfisher
import SnapKit
import UIKit

// 이미지 위에 겹치는 그라데이션을 표시하는 재사용 뷰입니다.
final class WallpaperGradientView: UIView {
    override class var layerClass: AnyClass { CAGradientLayer.self }
    init(colors: [UIColor] = [.clear, .black]) {
        super.init(frame: .zero)
        isUserInteractionEnabled = false
        (layer as? CAGradientLayer)?.colors = colors.map(\.cgColor)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

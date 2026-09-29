//
//  WallpaperLayout.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Kingfisher
import SnapKit
import UIKit

/// Standard portrait artwork format (width : height = 4 : 5).
// 히어로와 이미지 그리드에서 공유하는 세로 4:5 비율을 계산합니다.
enum WallpaperLayout {
    static let heightToWidth: CGFloat = 5.0 / 4.0
    static func imageHeight(for width: CGFloat) -> CGFloat { width * heightToWidth }
}

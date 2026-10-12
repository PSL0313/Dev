//
//  WallpaperCategoryHeader.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Kingfisher
import SnapKit
import UIKit

// 시리즈 목록 상단의 카테고리 선택 영역을 표시하는 재사용 뷰입니다.
final class WallpaperCategoryHeader: UICollectionReusableView {
    let control = WallpaperCategoryControl()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(control)
        control.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(38)
        }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

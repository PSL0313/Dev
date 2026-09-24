//
//  UIView++.swift
//  flover9
//
//  Created by 박선린 on 9/2/26.
//


import UIKit

extension UIView {
    /// Safe Area 인셋 정보를 기반으로 현재 기기의 모서리 곡률을 안전하게 추론합니다.
    var estimatedScreenCornerRadius: CGFloat {
        // 윈도우의 safeAreaInsets 확보
        guard let window = self.window else { return 0 }
        let safeArea = window.safeAreaInsets

        // 하단 인셋 값에 따라 아이폰 라인업의 곡률을 매핑
        switch safeArea.bottom {
        case let bottom where bottom > 34:
            // iPhone 14 Pro, 15, 16 시리즈 등 (다이내믹 아일랜드 모델들)
            return 55.0
        case 34:
            // iPhone X, 11, 12, 13 시리즈 등 (일반 노치 모델들)
            return 47.0
        default:
            // iPhone SE 시리즈 등 (홈버튼이 있는 사각 스크린 모델)
            return 0.0
        }
    }

    /// 화면 곡률에 맞게 뷰의 모서리를 부드럽게 깎아줍니다.
    func applyScreenCornerRadius() {
        self.layer.cornerRadius = self.estimatedScreenCornerRadius
        self.layer.cornerCurve = .continuous // 아이폰 고유의 Squircle 곡률 스타일 적용
        self.layer.masksToBounds = true
    }
}

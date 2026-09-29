//
//  WallpaperCategory.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Foundation

// 배경화면 시리즈의 분류와 화면에 표시할 카테고리 이름을 정의합니다.
enum WallpaperCategory: String, CaseIterable, Codable {
    case general // 일반 이미지 배경화면
    case calendar // 달력이 포함된 배경화면
    case clock // 시계 테마 배경화면
    var title: String { // 카테고리 버튼 등에 표시할 한국어 이름
        switch self {
        case .general: "일반"
        case .calendar: "캘린더"
        case .clock: "시계"
        }
    }
}

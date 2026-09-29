//
//  WallpaperChoice.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Foundation

// 멤버·제작자·시리즈 선택 화면에서 사용하는 식별자와 표시 이름입니다.
struct WallpaperChoice: Identifiable, Equatable {
    let id: String // 항목을 구분하는 고유 식별자
    let title: String // 화면에 표시할 이름
}

//
//  WallpaperFilterOptions.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Foundation

// 검색 필터에서 선택할 수 있는 멤버·제작자·시리즈 목록입니다.
struct WallpaperFilterOptions {
    var members: [WallpaperChoice] = [] // 선택 가능한 멤버 목록
    var creators: [WallpaperChoice] = [] // 선택 가능한 제작자 목록
    var series: [WallpaperChoice] = [] // 선택 가능한 시리즈 목록
}

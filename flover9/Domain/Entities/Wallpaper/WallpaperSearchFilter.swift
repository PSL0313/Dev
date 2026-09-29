//
//  WallpaperSearchFilter.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Foundation

// 개별 배경화면 검색에 적용할 검색어와 필터 조건입니다.
struct WallpaperSearchFilter: Equatable {
    var query = "" // 검색창에 입력한 검색어
    var memberCode: String? // 선택한 멤버 코드; nil이면 멤버 제한 없음
    var category: WallpaperCategory? // 시리즈의 배경화면 분류; nil이면 해당 조건으로 제한하지 않음
    var creatorID: UUID? // 제작자의 profiles.id를 참조하는 식별자; nil이면 해당 조건으로 제한하지 않음
    var seriesID: UUID? // 소속 또는 작업 대상 시리즈의 식별자; nil이면 해당 조건으로 제한하지 않음
    var activeCount: Int { // 검색어를 제외하고 현재 선택된 필터 개수
        [memberCode, category?.rawValue, creatorID?.uuidString, seriesID?.uuidString].compactMap { $0 }.count
    }
}

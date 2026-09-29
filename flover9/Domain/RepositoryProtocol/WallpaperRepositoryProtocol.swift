//
//  WallpaperRepositoryProtocol.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Foundation

// 시리즈 조회와 개별 배경화면 검색을 위한 도메인 저장소 계약입니다.
protocol WallpaperRepositoryProtocol {
    func series(category: WallpaperCategory?, offset: Int, featuredOnly: Bool) async throws -> [WallpaperSeriesEntity]
    func wallpapers(in seriesID: UUID) async throws -> [WallpaperEntity]
    func search(_ filter: WallpaperSearchFilter, offset: Int) async throws -> [WallpaperEntity]
    func options() async throws -> WallpaperFilterOptions
}

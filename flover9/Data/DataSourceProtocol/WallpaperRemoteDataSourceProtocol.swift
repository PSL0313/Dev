//
//  WallpaperRemoteDataSourceProtocol.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Foundation

// 배경화면 원격 조회 구현이 제공해야 할 기능을 정의합니다.
protocol WallpaperRemoteDataSourceProtocol {
    func series(category: WallpaperCategory?, offset: Int, featuredOnly: Bool) async throws -> [WallpaperSeriesDTO]
    func wallpapers(in seriesID: UUID) async throws -> [WallpaperDTO]
    func search(_ filter: WallpaperSearchFilter, offset: Int) async throws -> [WallpaperDTO]
    func options() async throws -> WallpaperFilterOptions
}

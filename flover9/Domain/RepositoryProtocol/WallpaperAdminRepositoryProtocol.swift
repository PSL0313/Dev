//
//  WallpaperAdminRepositoryProtocol.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Foundation

// 관리 화면에서 사용하는 편집 권한 조회와 저장·삭제 기능의 계약입니다.
protocol WallpaperAdminRepositoryProtocol {
    func context() async throws -> WallpaperEditorContext
    func listSeries() async throws -> [WallpaperSeriesEntity]
    func listWallpapers(seriesID: UUID) async throws -> [WallpaperEntity]
    func saveSeries(_ draft: WallpaperSeriesDraft, isNew: Bool) async throws
    func saveWallpaper(_ draft: WallpaperDraft, isNew: Bool) async throws
    func deleteSeries(_ series: WallpaperSeriesEntity) async throws
    func deleteWallpaper(_ wallpaper: WallpaperEntity) async throws
}

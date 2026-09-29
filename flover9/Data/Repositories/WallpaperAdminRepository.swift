//
//  WallpaperAdminRepository.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Foundation

// 관리 DataSource에 시리즈·배경화면 조회와 변경 요청을 전달합니다.
final class WallpaperAdminRepository: WallpaperAdminRepositoryProtocol {
    nonisolated deinit {}
    private let source: WallpaperAdminRemoteDataSourceProtocol
    init(source: WallpaperAdminRemoteDataSourceProtocol) { self.source = source }
    func context() async throws -> WallpaperEditorContext { try await source.context() }
    func listSeries() async throws -> [WallpaperSeriesEntity] { try await source.listSeries() }
    func listWallpapers(seriesID: UUID) async throws -> [WallpaperEntity] {
        try await source.listWallpapers(seriesID: seriesID)
    }
    func saveSeries(_ draft: WallpaperSeriesDraft, isNew: Bool) async throws {
        try await source.saveSeries(draft, isNew: isNew)
    }
    func saveWallpaper(_ draft: WallpaperDraft, isNew: Bool) async throws {
        try await source.saveWallpaper(draft, isNew: isNew)
    }
    func deleteSeries(_ series: WallpaperSeriesEntity) async throws { try await source.deleteSeries(series) }
    func deleteWallpaper(_ wallpaper: WallpaperEntity) async throws { try await source.deleteWallpaper(wallpaper) }
}

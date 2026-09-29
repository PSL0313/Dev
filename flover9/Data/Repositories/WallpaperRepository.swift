//
//  WallpaperRepository.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Foundation

// 조회 DataSource를 통해 시리즈·배경화면·검색 필터 데이터를 제공합니다.
final class WallpaperRepository: WallpaperRepositoryProtocol {
    nonisolated deinit {}
    private let source: WallpaperRemoteDataSourceProtocol
    init(source: WallpaperRemoteDataSourceProtocol) { self.source = source }
    func series(category: WallpaperCategory?, offset: Int, featuredOnly: Bool) async throws -> [WallpaperSeriesEntity] {
        try await source.series(category: category, offset: offset, featuredOnly: featuredOnly).map { $0.entity() }
    }
    func wallpapers(in seriesID: UUID) async throws -> [WallpaperEntity] {
        try await source.wallpapers(in: seriesID).map { $0.entity() }
    }
    func search(_ filter: WallpaperSearchFilter, offset: Int) async throws -> [WallpaperEntity] {
        try await source.search(filter, offset: offset).map { $0.entity() }
    }
    func options() async throws -> WallpaperFilterOptions { try await source.options() }
}

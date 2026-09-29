//
//  BrowseWallpapersUseCase.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Foundation

// 시리즈 중심 조회와 개별 배경화면 검색에 필요한 조회 기능을 제공합니다.
final class BrowseWallpapersUseCase {
    // No actor-bound teardown; avoids an executor hop when released on iOS 26.2.
    nonisolated deinit {}
    private let repository: WallpaperRepositoryProtocol
    init(repository: WallpaperRepositoryProtocol) { self.repository = repository }
    func home(category: WallpaperCategory?, featuredOnly: Bool = false, offset: Int = 0) async throws
        -> [WallpaperSeriesEntity]
    {
        try await repository.series(category: category, offset: offset, featuredOnly: featuredOnly)
    }
    func detail(_ seriesID: UUID) async throws -> [WallpaperEntity] { try await repository.wallpapers(in: seriesID) }
    func search(_ filter: WallpaperSearchFilter, offset: Int = 0) async throws -> [WallpaperEntity] {
        try await repository.search(filter, offset: offset)
    }
    func options() async throws -> WallpaperFilterOptions { try await repository.options() }
}

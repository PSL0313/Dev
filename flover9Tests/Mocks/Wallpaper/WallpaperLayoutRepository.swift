//
//  WallpaperLayoutRepository.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Kingfisher
import UIKit
import XCTest
@testable import flover9

// 화면 렌더링 테스트에 사용할 시리즈와 배경화면 목록을 제공합니다.
@MainActor final class WallpaperLayoutRepository: WallpaperRepositoryProtocol {
    nonisolated deinit {}
    let imageURL = URL(string: "https://wallpaper-fixture.invalid/bundled-artwork.png")!
    lazy var seriesItems: [WallpaperSeriesEntity] = ["Autumn Moment", "Blooming Days", "Our Time", "Winter Glow"].map {
        title in
        .init(
            id: UUID(), title: title, creatorID: UUID(), category: .general, coverURL: imageURL, isFeatured: true,
            isPublished: true, createdAt: Date(), description: "가을의 분위기를 담은 배경화면 시리즈입니다.\n좋아하는 순간을 당신의 화면에 담아보세요.",
            creatorName: "Creator", wallpaperCount: 12)
    }
    lazy var items: [WallpaperEntity] = (0..<12).map { index in
        .init(
            id: UUID(), seriesID: seriesItems[0].id, mockupURL: imageURL,
            originalURL: imageURL, sortOrder: index, seriesTitle: seriesItems[0].title, category: .general,
            creatorID: seriesItems[0].creatorID, memberCodes: [], creatorName: "Creator")
    }
    func series(category: WallpaperCategory?, offset: Int, featuredOnly: Bool) async throws -> [WallpaperSeriesEntity] {
        offset == 0 ? seriesItems : []
    }
    func wallpapers(in seriesID: UUID) async throws -> [WallpaperEntity] { items }
    func search(_ filter: WallpaperSearchFilter, offset: Int) async throws -> [WallpaperEntity] {
        offset == 0 ? items : []
    }
    func options() async throws -> WallpaperFilterOptions { .init() }
}

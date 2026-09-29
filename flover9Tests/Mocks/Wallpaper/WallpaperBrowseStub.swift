//
//  WallpaperBrowseStub.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Supabase
import UIKit
import XCTest
@testable import flover9

// 검색 응답 완료 시점을 제어하여 이전 검색 결과가 무시되는지 검사합니다.
@MainActor final class WallpaperBrowseStub: WallpaperRepositoryProtocol {
    var pending: [String: CheckedContinuation<[WallpaperEntity], Error>] = [:]
    func series(category: WallpaperCategory?, offset: Int, featuredOnly: Bool) async throws -> [WallpaperSeriesEntity] {
        []
    }
    func wallpapers(in seriesID: UUID) async throws -> [WallpaperEntity] { [] }
    func search(_ filter: WallpaperSearchFilter, offset: Int) async throws -> [WallpaperEntity] {
        try await withCheckedThrowingContinuation { pending[filter.query] = $0 }
    }
    func options() async throws -> WallpaperFilterOptions { .init() }
}

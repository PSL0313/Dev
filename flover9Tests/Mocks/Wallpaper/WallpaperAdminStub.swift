//
//  WallpaperAdminStub.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Supabase
import UIKit
import XCTest
@testable import flover9

// 관리 저장소 호출 횟수를 기록하는 테스트용 저장소입니다.
@MainActor final class WallpaperAdminStub: WallpaperAdminRepositoryProtocol {
    var saves = 0
    func context() async throws -> WallpaperEditorContext {
        .init(userID: UUID(), canFeature: true, creators: [], members: [])
    }
    func listSeries() async throws -> [WallpaperSeriesEntity] { [] }
    func listWallpapers(seriesID: UUID) async throws -> [WallpaperEntity] { [] }
    func saveSeries(_ draft: WallpaperSeriesDraft, isNew: Bool) async throws { saves += 1 }
    func saveWallpaper(_ draft: WallpaperDraft, isNew: Bool) async throws { saves += 1 }
    func deleteSeries(_ series: WallpaperSeriesEntity) async throws {}
    func deleteWallpaper(_ wallpaper: WallpaperEntity) async throws {}
}

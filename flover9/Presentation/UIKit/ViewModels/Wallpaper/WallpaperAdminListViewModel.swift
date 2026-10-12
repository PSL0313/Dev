//
//  WallpaperAdminListViewModel.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Foundation

// 관리 가능한 시리즈 목록과 생성·수정·삭제의 데이터와 로딩·오류 상태를 관리합니다.
@MainActor final class WallpaperAdminListViewModel {
    nonisolated deinit {}
    let manage: ManageWallpapersUseCase // 편집 검증과 저장·삭제를 제공하는 UseCase
    let series: WallpaperSeriesEntity? // 상세 또는 관리 대상 시리즈; 관리 목록에서 nil이면 시리즈 전체 관리
    private(set) var seriesItems: [WallpaperSeriesEntity] = [] // 관리 가능한 시리즈 목록
    private(set) var wallpapers: [WallpaperEntity] = [] // 관리 중인 시리즈에 속한 배경화면 목록
    private(set) var canCreate = false // 최신 권한 확인 후에만 생성 버튼 허용
    private(set) var isLoading = false // 데이터를 불러오는 중인지 여부
    private(set) var error: String? // 화면에 표시할 오류 메시지
    var onChange: (() -> Void)? // 상태 변경 후 화면 갱신을 요청하는 콜백
    init(manage: ManageWallpapersUseCase, series: WallpaperSeriesEntity? = nil) {
        self.manage = manage
        self.series = series
    }
    func load() {
        guard !isLoading else { return }
        isLoading = true
        canCreate = false
        error = nil
        onChange?()
        Task { [weak self] in
            guard let self else { return }
            do {
                let context = try await manage.context()
                canCreate = context.canCreate
                if let series {
                    wallpapers = try await manage.wallpapers(seriesID: series.id)
                } else {
                    seriesItems = try await manage.series()
                }
            } catch {
                seriesItems = []
                wallpapers = []
                canCreate = false
                self.error = error.localizedDescription
            }
            isLoading = false
            onChange?()
        }
    }
    func delete(series: WallpaperSeriesEntity) { perform { try await self.manage.deleteSeries(series) } }
    func delete(wallpaper: WallpaperEntity) { perform { try await self.manage.deleteWallpaper(wallpaper) } }
    private func perform(_ operation: @escaping () async throws -> Void) {
        guard !isLoading else { return }
        isLoading = true
        error = nil
        onChange?()
        Task { [weak self] in
            guard let self else { return }
            do {
                try await operation()
                isLoading = false
                load()
            } catch {
                self.error = error.localizedDescription
                isLoading = false
                onChange?()
            }
        }
    }
}

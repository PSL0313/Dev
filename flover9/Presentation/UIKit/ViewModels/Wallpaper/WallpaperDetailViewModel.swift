//
//  WallpaperDetailViewModel.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Foundation

// 선택한 시리즈와 소속 배경화면 목록의 데이터와 로딩·오류 상태를 관리합니다.
@MainActor final class WallpaperDetailViewModel {
    let series: WallpaperSeriesEntity // 상세 또는 관리 대상 시리즈; 관리 목록에서 nil이면 시리즈 전체 관리
    private let browse: BrowseWallpapersUseCase // 조회·검색 기능을 제공하는 UseCase
    private var task: Task<Void, Never>? // 현재 조회 작업; 새 조회나 화면 정리 시 취소에 사용
    private(set) var items: [WallpaperEntity] = [] // 화면에 표시할 조회 결과 목록
    private(set) var error: String? // 화면에 표시할 오류 메시지
    private(set) var isLoading = false // 데이터를 불러오는 중인지 여부
    var onChange: (() -> Void)? // 상태 변경 후 화면 갱신을 요청하는 콜백
    init(series: WallpaperSeriesEntity, browse: BrowseWallpapersUseCase) {
        self.series = series
        self.browse = browse
    }
    func load() {
        guard !isLoading else { return }
        isLoading = true
        error = nil
        onChange?()
        task = Task { [weak self] in
            guard let self else { return }
            do { items = try await browse.detail(series.id) } catch { self.error = error.localizedDescription }
            guard !Task.isCancelled else { return }
            isLoading = false
            onChange?()
        }
    }
    deinit { task?.cancel() }
}

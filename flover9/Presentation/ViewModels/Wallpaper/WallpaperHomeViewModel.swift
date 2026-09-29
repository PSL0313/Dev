//
//  WallpaperHomeViewModel.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Foundation

// 히어로·카테고리와 추천·최신 시리즈의 데이터와 로딩·오류 상태를 관리합니다.
@MainActor final class WallpaperHomeViewModel {
    private let browse: BrowseWallpapersUseCase // 조회·검색 기능을 제공하는 UseCase
    private var task: Task<Void, Never>? // 현재 조회 작업; 새 조회나 화면 정리 시 취소에 사용
    private var generation = UUID() // 조회 세대를 구분하여 뒤늦게 도착한 이전 응답을 무시하는 값
    private(set) var series: [WallpaperSeriesEntity] = [] // 홈에 표시할 최신 시리즈 목록
    private(set) var featured: [WallpaperSeriesEntity] = [] // 홈 추천 영역에 표시할 시리즈 목록
    private(set) var error: String? // 화면에 표시할 오류 메시지
    private(set) var category: WallpaperCategory? // 현재 선택한 카테고리; nil이면 전체
    private(set) var isLoading = false // 데이터를 불러오는 중인지 여부
    var onChange: (() -> Void)? // 상태 변경 후 화면 갱신을 요청하는 콜백
    init(browse: BrowseWallpapersUseCase) { self.browse = browse }
    func load(category: WallpaperCategory? = nil) {
        self.category = category
        task?.cancel()
        generation = UUID()
        let token = generation
        isLoading = true
        error = nil
        onChange?()
        task = Task { [weak self] in
            guard let self else { return }
            do {
                async let latest = browse.home(category: category)
                async let picks = browse.home(category: category, featuredOnly: true)
                let (newSeries, newFeatured) = try await (latest, picks)
                guard token == generation && !Task.isCancelled else { return }
                series = newSeries
                featured = newFeatured
            } catch {
                guard token == generation && !Task.isCancelled else { return }
                self.error = error.localizedDescription
            }
            isLoading = false
            onChange?()
        }
    }
    deinit { task?.cancel() }
}

//
//  WallpaperSeriesListViewModel.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Foundation

// 카테고리별 시리즈 목록의 데이터와 로딩·오류 상태를 관리합니다.
@MainActor final class WallpaperSeriesListViewModel {
    private let browse: BrowseWallpapersUseCase // 조회·검색 기능을 제공하는 UseCase
    private var task: Task<Void, Never>? // 현재 조회 작업; 새 조회나 화면 정리 시 취소에 사용
    private var generation = UUID() // 조회 세대를 구분하여 뒤늦게 도착한 이전 응답을 무시하는 값
    private(set) var items: [WallpaperSeriesEntity] = [] // 화면에 표시할 조회 결과 목록
    private(set) var category: WallpaperCategory? // 현재 선택한 카테고리; nil이면 전체
    private(set) var error: String? // 화면에 표시할 오류 메시지
    private(set) var isLoading = false // 데이터를 불러오는 중인지 여부
    private(set) var canLoadMore = true // 다음 페이지를 추가 조회할 수 있는지 여부
    init(browse: BrowseWallpapersUseCase) { self.browse = browse }
    var onChange: (() -> Void)? // 상태 변경 후 화면 갱신을 요청하는 콜백
    func reload(category: WallpaperCategory? = nil) {
        self.category = category
        task?.cancel()
        generation = UUID()
        items = []
        isLoading = false
        canLoadMore = true
        loadMore()
    }
    func loadMore() {
        guard !isLoading && canLoadMore else { return }
        isLoading = true
        error = nil
        onChange?()
        let token = generation
        let offset = items.count
        let category = category
        task = Task { [weak self] in
            guard let self else { return }
            do {
                let page = try await browse.home(category: category, offset: offset)
                guard token == generation && !Task.isCancelled else { return }
                let known = Set(items.map(\.id))
                items += page.filter { !known.contains($0.id) }
                canLoadMore = page.count == 30
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

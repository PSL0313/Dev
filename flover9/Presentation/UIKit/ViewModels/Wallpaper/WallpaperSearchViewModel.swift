//
//  WallpaperSearchViewModel.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Foundation

// 검색어와 필터를 적용한 개별 배경화면 검색의 데이터와 로딩·오류 상태를 관리합니다.
@MainActor final class WallpaperSearchViewModel {
    private let browse: BrowseWallpapersUseCase // 조회·검색 기능을 제공하는 UseCase
    private var task: Task<Void, Never>? // 현재 조회 작업; 새 조회나 화면 정리 시 취소에 사용
    private var generation = UUID() // 조회 세대를 구분하여 뒤늦게 도착한 이전 응답을 무시하는 값
    var filter = WallpaperSearchFilter() // 현재 검색어와 필터 조건
    private(set) var results: [WallpaperEntity] = [] // 검색 조건에 맞는 배경화면 결과
    private(set) var options = WallpaperFilterOptions() // 필터 화면에서 선택 가능한 항목 목록
    private(set) var error: String? // 화면에 표시할 오류 메시지
    private(set) var isLoading = false // 데이터를 불러오는 중인지 여부
    private(set) var canLoadMore = true // 다음 페이지를 추가 조회할 수 있는지 여부
    var onChange: (() -> Void)? // 상태 변경 후 화면 갱신을 요청하는 콜백
    init(browse: BrowseWallpapersUseCase) { self.browse = browse }
    func load(debounce: Bool = false) {
        task?.cancel()
        generation = UUID()
        results = []
        isLoading = false
        canLoadMore = true
        fetch(offset: 0, debounce: debounce)
    }
    func loadMore() {
        guard !isLoading && canLoadMore else { return }
        fetch(offset: results.count, debounce: false)
    }
    func loadOptions() async throws { options = try await browse.options() }
    private func fetch(offset: Int, debounce: Bool) {
        isLoading = true
        error = nil
        onChange?()
        let token = generation
        let filter = filter
        task = Task { [weak self] in
            guard let self else { return }
            do {
                if debounce { try await Task.sleep(nanoseconds: 250_000_000) }
                let page = try await browse.search(filter, offset: offset)
                guard token == generation && !Task.isCancelled else { return }
                let known = Set(results.map(\.id))
                results += page.filter { !known.contains($0.id) }
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

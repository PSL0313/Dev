//
//  AdminListViewModel.swift
//  flover9
//
//  Created by 박선린 on 9/24/26.
//

import Foundation

@MainActor
final class AdminListViewModel {
    enum Route {
        case create
        case edit(AdminContent)
        case confirmDelete(AdminContent)
        case message(String, String)
    }

    var onChange: (() -> Void)?
    var onRoute: ((Route) -> Void)?

    let category: AdminCategory
    private(set) var items: [AdminContent] = []
    private(set) var isLoading = false
    private var isDeleting = false
    private(set) var canLoadMore = false
    private(set) var errorMessage: String?

    private let useCase: AdminUseCaseProtocol
    private let logger: ErrorLogging
    private var query = ""
    private var offset = 0
    private var generation = 0
    private var task: Task<Void, Never>?

    init(category: AdminCategory, useCase: AdminUseCaseProtocol, logger: ErrorLogging) {
        self.category = category
        self.useCase = useCase
        self.logger = logger
    }

    // MARK: - 새 검색과 새로고침은 이전 응답이 뒤늦게 화면을 덮지 못하게 한다.
    func reload(query: String? = nil) {
        // 삭제 요청은 새로고침으로 취소하지 않고 서버 결과를 기다립니다.
        guard !isDeleting else { return }
        task?.cancel()
        generation += 1
        if let query { self.query = query.trimmingCharacters(in: .whitespacesAndNewlines) }
        items = []
        offset = 0
        isLoading = false
        canLoadMore = true
        loadMore()
    }

    func loadMore() {
        guard !isLoading, canLoadMore else { return }
        isLoading = true
        errorMessage = nil
        onChange?()
        let currentGeneration = generation

        task = Task { [weak self] in
            guard let self else { return }
            do {
                let page = try await useCase.fetchItems(category: category, offset: offset, query: query)
                guard !Task.isCancelled, currentGeneration == generation else { return }
                let existingIDs = Set(items.map(\.id))
                items.append(contentsOf: page.filter { !existingIDs.contains($0.id) })
                offset += page.count
                canLoadMore = page.count == 30
            } catch {
                guard !Task.isCancelled, currentGeneration == generation else { return }
                let failure = error as? AdminError ?? .serverUnavailable
                errorMessage = failure.userMessage
                if failure == .permissionDenied { items = [] }
                await logger.record(failure)
            }
            isLoading = false
            onChange?()
        }
    }

    func select(_ index: Int) {
        guard items.indices.contains(index), !isLoading else { return }
        onRoute?(.edit(items[index]))
    }

    func create() {
        guard !isLoading else { return }
        onRoute?(.create)
    }

    func requestDeletion(_ index: Int) {
        guard items.indices.contains(index), !isLoading else { return }
        onRoute?(.confirmDelete(items[index]))
    }

    // MARK: - 삭제 완료와 R2 정리 대기를 구분해서 안내
    func delete(_ item: AdminContent) {
        guard !isLoading else { return }
        isDeleting = true
        isLoading = true
        onChange?()
        task = Task { [weak self] in
            guard let self else { return }
            do {
                let queued = try await useCase.delete(item)
                isDeleting = false
                isLoading = false
                reload()
                onRoute?(.message(
                    "삭제 완료",
                    queued ? "목록에서 삭제했어요. 연결된 파일은 서버의 정리 작업으로 삭제됩니다." : "항목을 삭제했어요."
                ))
            } catch {
                let failure = error as? AdminError ?? .serverUnavailable
                isDeleting = false
                isLoading = false
                onChange?()
                onRoute?(.message("삭제하지 못했어요", failure.userMessage))
                await logger.record(failure)
            }
        }
    }
}

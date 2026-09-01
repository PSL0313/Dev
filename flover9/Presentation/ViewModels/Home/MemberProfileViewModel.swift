//
//  MemberProfileViewModel.swift
//  flover9
//
//  Created by 박선린 on 8/27/26.
//

import Foundation

final class MemberProfileViewModel {
    enum Route {
        case moveToFeedDetail(feed: FeedEntity, mediaItems: [FeedImageEntity])
        case failed(String)
    }

    enum Input {
        case moveToFeedDetail(FeedEntity)
    }

    private enum Constant {
        static let pageSize = 30
    }

    // MARK: - Properties
    let member: MemberEntity
    private(set) var feeds: [FeedEntity] = []
    private(set) var isInitialLoading = false
    private(set) var isLoadingMore = false
    private(set) var hasReachedEndOfFeeds = false
    private(set) var errorMessage: String?
    private(set) var isLoadingFeedDetail = false

    var onRoute: ((Route) -> Void)?

    var memberId: String? { member.code }
    var title: String { member.displayName }
    var displayName: String { member.displayName }
    var subtitle: String { "@\(member.code)" }
    var postCountText: String { "\(feeds.count)" }
    var photoCountText: String {
        "\(feeds.reduce(0) { $0 + $1.contentCount })"
    }
    var profileImageURL: URL? { member.profileImageURL }
    var itemCount: Int { feeds.count }
    var canTriggerLoadMore: Bool {
        !feeds.isEmpty && !isInitialLoading && !isLoadingMore && !hasReachedEndOfFeeds
    }
    var footerMessage: String? {
        if hasReachedEndOfFeeds && !feeds.isEmpty { return "모든 피드를 불러왔어요" }
        if let errorMessage, !feeds.isEmpty { return errorMessage }
        return nil
    }


    // MARK: - UseCase
    private let FeedReadUseCase: FeedReadUseCaseProtocol

    // MARK: - Initializer
    init(member: MemberEntity, FeedReadUseCase: FeedReadUseCaseProtocol) {
        self.member = member
        self.FeedReadUseCase = FeedReadUseCase
    }

    // MARK: - Deinit
    deinit {
        print("MemberProfileViewModel deinit")
    }

    @MainActor
    func loadIfNeeded() async {
        guard feeds.isEmpty, !isInitialLoading else { return }
        await loadFirstPage(reset: true)
    }

    @MainActor
    func reload() async {
        guard !isInitialLoading, !isLoadingMore else { return }
        await loadFirstPage(reset: true)
    }

    @MainActor
    func beginLoadMoreIfNeeded() -> Bool {
        guard canTriggerLoadMore else { return false }

        isLoadingMore = true
        errorMessage = nil
        return true
    }

    @MainActor
    func performLoadMore() async {
        guard isLoadingMore else { return }
        defer { isLoadingMore = false }

        do {
            let page = try await fetchNextPage()
            feeds.append(contentsOf: page)
            hasReachedEndOfFeeds = page.count < Constant.pageSize
        } catch {
            errorMessage = "추가 피드를 불러오지 못했어요"
        }
    }

    func feed(at index: Int) -> FeedEntity? {
        guard feeds.indices.contains(index) else { return nil }
        return feeds[index]
    }

    func action(_ input: Input) {
        switch input {
        case .moveToFeedDetail(let feed):
            loadFeedDetail(feed)
        }
    }
}

private extension MemberProfileViewModel {
    @MainActor
    func loadFirstPage(reset: Bool) async {
        isInitialLoading = true
        errorMessage = nil
        defer { isInitialLoading = false }

        if reset {
            FeedReadUseCase.reset(memberCode: memberCode)
            hasReachedEndOfFeeds = false
        }

        do {
            let page = try await fetchNextPage()
            feeds = page
            hasReachedEndOfFeeds = page.count < Constant.pageSize
        } catch {
            errorMessage = "피드를 불러오지 못했어요"
        }
    }

    var memberCode: MemberCode? {
        MemberCode(rawValue: member.code)
    }

    func fetchNextPage() async throws -> [FeedEntity] {
        try await FeedReadUseCase.fetchFeeds(
            memberCode: memberCode,
            limit: Constant.pageSize
        )
    }

    func loadFeedDetail(_ feed: FeedEntity) {
        guard !isLoadingFeedDetail else { return }
        isLoadingFeedDetail = true

        Task { @MainActor [weak self] in
            guard let self else { return }
            defer { isLoadingFeedDetail = false }

            do {
                let mediaItems = try await FeedReadUseCase.fetchFeedMedia(feedID: feed.id)
                onRoute?(.moveToFeedDetail(feed: feed, mediaItems: mediaItems))
            } catch let error as FeedError {
                onRoute?(.failed(error.userMessage))
            } catch {
                onRoute?(.failed(FeedError.unknown.userMessage))
            }
        }
    }
}

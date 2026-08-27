//
//  MemberProfileViewModel.swift
//  flover9
//
//  Created by 박선린 on 8/27/26.
//

import Foundation

final class MemberProfileViewModel {
    private enum Constant {
        static let pageSize = 30
    }

    // MARK: - Properties
    let member: MemberEntity
    private(set) var feeds: [FeedData] = []
    private(set) var isInitialLoading = false
    private(set) var isLoadingMore = false
    private(set) var hasReachedEndOfFeeds = false
    private(set) var errorMessage: String?

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
            feeds.append(contentsOf: page.map(FeedData.init))
            hasReachedEndOfFeeds = page.count < Constant.pageSize
        } catch {
            errorMessage = "추가 피드를 불러오지 못했어요"
        }
    }

    func feed(at index: Int) -> FeedData? {
        guard feeds.indices.contains(index) else { return nil }
        return feeds[index]
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
            feeds = page.map(FeedData.init)
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
}

struct FeedData {
    let id: UUID
    let thumbnailURL: String?
    let mediaItems: [FeedMediaItem] = []
    let source: FeedSource
    let captureDate: Date
    let contentCount: Int

    var isOlderThanOneYear: Bool {
        captureDate < (Calendar.current.date(byAdding: .year, value: -1, to: .now) ?? .now)
    }

    init(_ feed: FeedEntity) {
        id = feed.id
        thumbnailURL = feed.thumbnailURL?.absoluteString
        source = FeedSource(rawValue: feed.source) ?? .official
        captureDate = feed.captureDate
        contentCount = feed.contentCount
    }
}

struct FeedMediaItem {
    let url: String
    let isVideo: Bool
}

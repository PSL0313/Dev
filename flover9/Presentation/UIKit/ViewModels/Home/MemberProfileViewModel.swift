//
//  MemberProfileViewModel.swift
//  flover9
//
//  Created by 박선린 on 8/27/26.
//

import Foundation

@MainActor
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
    private(set) var isLoadingNewFeeds = false
    private(set) var hasReachedEndOfFeeds = false
    private(set) var errorMessage: String?
    private(set) var isLoadingFeedDetail = false

    var onRoute: ((Route) -> Void)?

    // 멤버 프로필 이미지 URL 반환
    var profileImageURL: URL? {
        member.profileImageURL
    }

    // 조회된 피드 개수 반환
    var itemCount: Int {
        feeds.count
    }

    // 추가 페이지 조회 가능 여부 확인
    var canTriggerLoadMore: Bool {
        !feeds.isEmpty &&
        !isInitialLoading &&
        !isLoadingMore &&
        !isLoadingNewFeeds &&
        !hasReachedEndOfFeeds
    }

    // 피드 목록 하단 안내 메시지 반환
    var footerMessage: String? {
        // 모든 피드 조회 완료 확인
        if hasReachedEndOfFeeds && !feeds.isEmpty {
            return "모든 피드를 불러왔어요"
        }

        // 피드 조회 오류 확인
        if let errorMessage, !feeds.isEmpty {
            return errorMessage
        }

        return nil
    }

    // 멤버 코드 반환
    private var memberCode: MemberCode? {
        MemberCode(rawValue: member.code)
    }

    // MARK: - UseCase
    private let FeedReadUseCase: FeedReadUseCaseProtocol

    // MARK: - Initializer
    init(
        member: MemberEntity,
        FeedReadUseCase: FeedReadUseCaseProtocol
    ) {
        self.member = member
        self.FeedReadUseCase = FeedReadUseCase
    }

    // MARK: - Deinit
    deinit {
        print("MemberProfileViewModel deinit")
    }

    // MARK: - Methods

    // 피드가 비어 있는 경우 첫 페이지 조회
    func loadIfNeeded() async {
        // 초기 조회 필요 여부 확인
        guard feeds.isEmpty,
              !isInitialLoading,
              !isLoadingMore,
              !isLoadingNewFeeds else {
            return
        }

        await loadFirstPage(reset: true)
    }

    // 기존 피드보다 새로운 피드 조회 및 삽입
    func reload() async {
        // 다른 피드 조회 작업 진행 여부 확인
        guard !isLoadingNewFeeds,
              !isInitialLoading,
              !isLoadingMore else {
            return
        }

        isLoadingNewFeeds = true
        errorMessage = nil

        defer {
            isLoadingNewFeeds = false
        }

        do {
            let newFeeds = try await fetchNewFeed()

            // 기존 피드 ID 확인
            var existingIDs = Set(feeds.map(\.id))

            // 중복되지 않은 신규 피드 추출
            let uniqueFeeds = newFeeds.filter {
                existingIDs.insert($0.id).inserted
            }

            // 신규 피드 존재 여부 확인
            guard !uniqueFeeds.isEmpty else {
                return
            }

            feeds.insert(contentsOf: uniqueFeeds, at: 0)

        } catch {
            errorMessage = "신규 피드를 불러오지 못했어요"
        }
    }

    // 추가 페이지 조회 시작 가능 여부 확인 및 상태 변경
    func beginLoadMoreIfNeeded() -> Bool {
        // 추가 페이지 조회 가능 여부 확인
        guard canTriggerLoadMore else {
            return false
        }

        isLoadingMore = true
        errorMessage = nil

        return true
    }

    // 다음 페이지 조회 및 기존 피드 목록에 추가
    func performLoadMore() async {
        // 추가 페이지 조회 시작 여부 확인
        guard isLoadingMore,
              !isInitialLoading,
              !isLoadingNewFeeds else {
            return
        }

        defer {
            isLoadingMore = false
        }

        do {
            let page = try await fetchNextPage()

            // 기존 피드 ID 확인
            var existingIDs = Set(feeds.map(\.id))

            // 중복되지 않은 피드 추출
            let uniqueFeeds = page.filter {
                existingIDs.insert($0.id).inserted
            }

            feeds.append(contentsOf: uniqueFeeds)

            // 마지막 페이지 여부 확인
            hasReachedEndOfFeeds = page.count < Constant.pageSize

        } catch {
            errorMessage = "추가 피드를 불러오지 못했어요"
        }
    }
    
    // 인덱스에 해당하는 피드 반환
    func feed(at index: Int) -> FeedEntity? {
        // 유효한 인덱스 확인
        guard feeds.indices.contains(index) else {
            return nil
        }

        return feeds[index]
    }

    // 사용자 입력에 따른 액션 처리
    func action(_ input: Input) {
        // 입력 액션 분기
        switch input {
        case .moveToFeedDetail(let feed):
            loadFeedDetail(feed)
        }
    }
}

// MARK: - Private Methods
private extension MemberProfileViewModel {

    // 페이지 조회 상태 초기화 및 첫 페이지 조회
    func loadFirstPage(reset: Bool) async {
        // 다른 피드 조회 작업 진행 여부 확인
        guard !isInitialLoading,
              !isLoadingMore,
              !isLoadingNewFeeds else {
            return
        }

        isInitialLoading = true
        errorMessage = nil

        defer {
            isInitialLoading = false
        }

        // 기존 페이지 조회 상태 초기화
        if reset {
            FeedReadUseCase.reset(memberCode: memberCode)
            hasReachedEndOfFeeds = false
            feeds.removeAll()
        }

        do {
            let page = try await fetchNextPage()

            feeds = page

            // 마지막 페이지 여부 확인
            hasReachedEndOfFeeds = page.count < Constant.pageSize

        } catch {
            errorMessage = "피드를 불러오지 못했어요"
        }
    }

    // 다음 페이지 피드 조회
    func fetchNextPage() async throws -> [FeedEntity] {
        try await FeedReadUseCase.fetchFeeds(
            memberCode: memberCode,
            limit: Constant.pageSize
        )
    }

    // 최신 피드 조회
    func fetchNewFeed() async throws -> [FeedEntity] {
        try await FeedReadUseCase.fetchNewFeeds(
            memberCode: memberCode
        )
    }

    // 피드 미디어 조회 후 상세 화면 이동
    func loadFeedDetail(_ feed: FeedEntity) {
        // 피드 상세 조회 중복 실행 확인
        guard !isLoadingFeedDetail else {
            return
        }

        isLoadingFeedDetail = true

        Task { [weak self] in
            // ViewModel 해제 여부 확인
            guard let self else {
                return
            }

            defer {
                isLoadingFeedDetail = false
            }

            do {
                let mediaItems = try await FeedReadUseCase.fetchFeedMedia(
                    feedID: feed.id
                )

                onRoute?(
                    .moveToFeedDetail(
                        feed: feed,
                        mediaItems: mediaItems
                    )
                )

            } catch let error as FeedError {
                // 정의된 피드 오류 처리
                onRoute?(.failed(error.userMessage))

            } catch {
                // 기타 오류 처리
                onRoute?(.failed(FeedError.unknown.userMessage))
            }
        }
    }
}

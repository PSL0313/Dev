//
//  FeedReadUseCase.swift
//  flover9
//
//  Created by 박선린 on 8/27/26.
//
import Foundation

// MARK: - 피드 읽기 전용 UseCase
final class FeedReadUseCase: FeedReadUseCaseProtocol {

    // MARK: - Repository

    private let repository: FeedRepositoryProtocol

    init(feedRepository: FeedRepositoryProtocol) {
        self.repository = feedRepository
    }

    func fetchFeeds(
        memberCode: MemberCode?,
        offset: Int,
        limit: Int,
        refresh: Bool
    ) async throws -> [FeedEntity] {
        try await repository.fetchFeeds(
            memberCode: memberCode,
            offset: offset,
            limit: limit,
            refresh: refresh
        )
    }

    // MARK: - 선택한 피드의 상세 미디어 조회

    func fetchFeedMedia(
        feedID: UUID
    ) async throws -> [FeedImageEntity] {
        try await repository.fetchFeedMedia(feedID: feedID)
    }
}

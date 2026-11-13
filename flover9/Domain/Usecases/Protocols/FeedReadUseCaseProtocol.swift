//
//  FeedReadUseCaseProtocol.swift
//  flover9
//
//  Created by 박선린 on 8/8/26.
//
import Foundation

// MARK: - 피드 읽기 전용 UseCase Protocol
protocol FeedReadUseCaseProtocol {

    /// 피드 목록 조회
    func fetchFeeds(
        memberCode: MemberCode?,
        offset: Int,
        limit: Int,
        refresh: Bool
    ) async throws -> [FeedEntity]

    func fetchFeedMedia(
        feedID: UUID
    ) async throws -> [FeedImageEntity]
}

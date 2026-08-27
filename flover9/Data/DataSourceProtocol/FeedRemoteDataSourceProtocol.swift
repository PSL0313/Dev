//
//  FeedRemoteDataSource.swift
//  flover9
//
//  Created by 박선린 on 8/7/26.
//

import Foundation

// MARK: - 피드 목록과 상세 미디어를 원격 저장소에서 조회하는 인터페이스
protocol FeedRemoteDataSourceProtocol {
    func fetchFeeds(
        memberCode: MemberCode?,
        limit: Int,
        offset: Int
    ) async throws -> FeedPageDTO

    func fetchFeedMedia(
        feedID: UUID
    ) async throws -> [FeedImageDTO]
}

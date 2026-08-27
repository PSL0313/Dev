//
//  FeedResponseUsecase.swift
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
        limit: Int
    ) async throws -> [FeedEntity]

    /// 선택한 피드의 상세 미디어 조회
    func fetchFeedMedia(
        feedID: UUID
    ) async throws -> [FeedImageEntity]

    /// 특정 멤버의 피드 조회 위치 초기화
    func reset(memberCode: MemberCode?)

    /// 전체 피드 조회 위치 초기화
    func resetAll()
}

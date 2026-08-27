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

    // MARK: - Pagination

    /// 멤버별 현재까지 조회한 피드 개수
    /// nil → 전체 피드
    private var offsetByMember: [MemberCode?: Int] = [:]

    /// 더 이상 가져올 피드가 없는 조회 조건
    /// nil → 전체 피드
    private var fullyFetchedMembers: Set<MemberCode?> = []


    init(feedRepository: FeedRepositoryProtocol) {
        self.repository = feedRepository
    }


    // MARK: - 피드 목록 조회

    func fetchFeeds(
        memberCode: MemberCode? = nil,
        limit: Int
    ) async throws -> [FeedEntity] {

        guard limit > 0 else {
            return []
        }

        // 이미 모든 피드를 가져온 경우 추가 조회 차단
        guard !fullyFetchedMembers.contains(memberCode) else {
            return []
        }

        // 현재 조회 위치
        let offset = offsetByMember[memberCode, default: 0]

        // Repository에 요청 범위 전달
        let feeds = try await repository.fetchFeeds(
            memberCode: memberCode,
            offset: offset,
            limit: limit
        )

        // 실제로 가져온 개수만큼 조회 위치 이동
        offsetByMember[memberCode, default: 0] += feeds.count

        // 요청한 개수보다 적게 반환된 경우 마지막 데이터로 판단
        if feeds.count < limit {
            fullyFetchedMembers.insert(memberCode)
        }

        return feeds
    }


    // MARK: - 선택한 피드의 상세 미디어 조회

    func fetchFeedMedia(
        feedID: UUID
    ) async throws -> [FeedImageEntity] {
        try await repository.fetchFeedMedia(feedID: feedID)
    }


    // MARK: - Reset

    /// 특정 멤버의 피드 조회 위치 초기화
    func reset(memberCode: MemberCode?) {
        offsetByMember[memberCode] = nil
        fullyFetchedMembers.remove(memberCode)
    }

    /// 전체 피드 조회 위치 초기화
    func resetAll() {
        offsetByMember.removeAll()
        fullyFetchedMembers.removeAll()
    }
}

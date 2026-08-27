//
//  FeedCache.swift
//  flover9
//
//  Created by 박선린 on 8/27/26.
//

import Foundation

actor FeedCache: FeedCacheProtocol {

    // 서버에서 가져와 캐싱한 피드
    // nil → 전체 피드
    // MemberCode → 해당 멤버 피드
    private var feedsByMember: [MemberCode?: [FeedResponseDTO]] = [:]

    // 서버의 데이터를 전부 가져온 멤버
    private var fullyFetchedMembers: Set<MemberCode?> = []

    // 피드별 이미지 캐시
    private var imagesByFeedID: [UUID: [FeedImageDTO]] = [:]

    // 이미지 조회를 완료한 피드 ID
    private var fetchedImageFeedIDs: Set<UUID> = []


    // MARK: - Read
    /// 캐시에 저장된 피드 중 요청한 범위의 데이터를 반환
    func fetch(
        memberCode: MemberCode? = nil,
        offset: Int,
        limit: Int
    ) -> [FeedResponseDTO] {
        guard limit > 0, offset >= 0 else { return [] }

        let feeds = feedsByMember[memberCode, default: []]

        guard offset < feeds.count else {
            return []
        }

        let end = min(offset + limit, feeds.count)

        return Array(feeds[offset..<end])
    }

    /// 캐시에 저장된 피드의 이미지 데이터 전달
    func images(for feedID: UUID) -> [FeedImageDTO]? {
        guard fetchedImageFeedIDs.contains(feedID) else {
            return nil
        }

        return imagesByFeedID[feedID, default: []]
    }

    // MARK: - Write

    /// DataSource에서 새로 받아온 데이터를 캐시에 추가
    func append(
        _ feeds: [FeedResponseDTO],
        memberCode: MemberCode? = nil
    ) {
        guard !feeds.isEmpty else { return }

        feedsByMember[memberCode, default: []].append(contentsOf: feeds)
    }

    /// DataSource에서 새로 받아온 이미지 데이터를 캐시에  추가
    func saveImages(
        _ images: [FeedImageDTO],
        for feedID: UUID
    ) {
        imagesByFeedID[feedID] = images
        fetchedImageFeedIDs.insert(feedID)
    }


    // MARK: - Server Pagination

    /// 캐시에 저장된 피드 개수 반환
    func fetchedCount(for memberCode: MemberCode? = nil) -> Int {
        feedsByMember[memberCode, default: []].count
    }

    /// 서버의 데이터를 전부 가져왔는지 확인
    func isFullyFetched(_ memberCode: MemberCode? = nil) -> Bool {
        fullyFetchedMembers.contains(memberCode)
    }

    /// 서버의 데이터를 전부 가져왔다고 기록
    func markAsFullyFetched(_ memberCode: MemberCode? = nil) {
        fullyFetchedMembers.insert(memberCode)
    }

    // MARK: - Reset

    /// 특정 멤버 캐시 초기화
    func reset(_ memberCode: MemberCode? = nil) {
        feedsByMember[memberCode] = nil
        fullyFetchedMembers.remove(memberCode)
        ///참고: 피드 상세 이미지 관련된 캐시는 지우지 않음
    }

    /// 전체 캐시 초기화
    func resetAll() {
        feedsByMember.removeAll()
        fullyFetchedMembers.removeAll()
        imagesByFeedID.removeAll()
        fetchedImageFeedIDs.removeAll()
    }
}

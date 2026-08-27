//
//  FeedCacheProtocol.swift
//  flover9
//
//  Created by 박선린 on 8/27/26.
//
import Foundation

protocol FeedCacheProtocol: Actor {

    // MARK: - Read

    /// 캐시에 저장된 피드 중 요청한 범위의 데이터를 반환
    func fetch(
        memberCode: MemberCode?,
        offset: Int,
        limit: Int
    ) -> [FeedResponseDTO]

    /// 캐시에 저장된 피드의 이미지 데이터 전달
    func images(
        for feedID: UUID
    ) -> [FeedImageDTO]?


    // MARK: - Write

    /// DataSource에서 새로 받아온 데이터를 캐시에 추가
    func append(
        _ feeds: [FeedResponseDTO],
        memberCode: MemberCode?
    )

    /// DataSource에서 새로 받아온 이미지 데이터를 캐시에 추가
    func saveImages(
        _ images: [FeedImageDTO],
        for feedID: UUID
    )


    // MARK: - Server Pagination

    /// 캐시에 저장된 피드 개수 반환
    func fetchedCount(
        for memberCode: MemberCode?
    ) -> Int

    /// 서버의 데이터를 전부 가져왔는지 확인
    func isFullyFetched(
        _ memberCode: MemberCode?
    ) -> Bool

    /// 서버의 데이터를 전부 가져왔다고 기록
    func markAsFullyFetched(
        _ memberCode: MemberCode?
    )


    // MARK: - Reset

    /// 특정 멤버 또는 전체 피드 캐시 초기화
    func reset(
        _ memberCode: MemberCode?
    )

    /// 전체 캐시 초기화
    func resetAll()
}

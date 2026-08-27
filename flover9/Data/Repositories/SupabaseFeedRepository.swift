//
//  SupabaseFeedRepository.swift
//  flover9
//
//  Created by 박선린 on 8/7/26.
//

import Foundation

// MARK: - 수파베이스에 저장된 피드 데이터를 가져오는 레퍼지토리
final class SupabaseFeedRepository: FeedRepositoryProtocol {

    // MARK: - DataSource
    private let datasource: FeedRemoteDataSourceProtocol

    // MARK: - Cache
    private let cache: FeedCacheProtocol

    init(
        datasource: FeedRemoteDataSourceProtocol,
        cache: FeedCacheProtocol
    ) {
        self.datasource = datasource
        self.cache = cache
    }


    // MARK: - 피드 목록 요약 조회
    func fetchFeeds(
        memberCode: MemberCode? = nil,
        offset: Int,
        limit: Int
    ) async throws -> [FeedEntity] {
        do {
            guard limit > 0, offset >= 0 else {
                return []
            }

            // Cache에서 요청한 범위의 피드 데이터 조회
            let cachedFeeds = await cache.fetch(
                memberCode: memberCode,
                offset: offset,
                limit: limit
            )

            // Cache에서 요청한 갯수만큼 가져온 경우 바로 Domain Entity 배열로 변환
            if cachedFeeds.count == limit {
                return try cachedFeeds.map { try $0.toEntity() }
            }

            // Cache 데이터는 부족하지만 원격 데이터를 전부 가져온 경우
            if await cache.isFullyFetched(memberCode) {
                return try cachedFeeds.map { try $0.toEntity() }
            }

            // Cache에서 부족한 갯수 계산
            let remainingLimit = limit - cachedFeeds.count

            // 원격에서 추가로 조회할 시작 위치
            let remoteOffset = offset + cachedFeeds.count

            // 부족한 범위의 원격 피드 DTO 목록 조회
            let feedPage = try await datasource.fetchFeeds(
                memberCode: memberCode,
                limit: remainingLimit,
                offset: remoteOffset
            )

            // 원격에서 가져온 피드 Cache 저장
            await cache.append(
                feedPage.feeds,
                memberCode: memberCode
            )

            // 추가적으로 가져올 원격 데이터가 없는 경우 Cache에 기록
            if !feedPage.hasMore {
                await cache.markAsFullyFetched(memberCode)
            }

            // 기존 Cache 데이터와 원격에서 새롭게 가져온 데이터 결합
            let feeds = cachedFeeds + feedPage.feeds

            // Domain Entity 배열로 변환
            return try feeds.map { try $0.toEntity() }

        } catch let error as FeedError {
            throw error // DTO 변환에서 발생한 Domain 오류 유지
        } catch {
            throw mapFeedError(error) // Data 오류를 Feed Domain 오류로 변환
        }
    }


    // MARK: - 선택한 피드의 상세 미디어 조회
    func fetchFeedMedia(feedID: UUID) async throws -> [FeedImageEntity] {
        do {
            // Cache에 저장된 미디어가 있는지 확인
            if let cachedMedia = await cache.images(for: feedID) {
                return try cachedMedia
                    .sorted { $0.sortOrder < $1.sortOrder }
                    .map { try $0.toEntity() }
            }

            // 원격 미디어 DTO 조회
            let media = try await datasource.fetchFeedMedia(
                feedID: feedID
            )

            // 원격에서 가져온 미디어 Cache 저장
            await cache.saveImages(
                media,
                for: feedID
            )

            // 표시 순서대로 Domain Entity 변환
            return try media
                .sorted { $0.sortOrder < $1.sortOrder }
                .map { try $0.toEntity() }

        } catch let error as FeedError {
            throw error // DTO 변환에서 발생한 Domain 오류 유지
        } catch {
            throw mapFeedError(error) // Data 오류를 Feed Domain 오류로 변환
        }
    }


    // MARK: - Data 계층 오류를 피드 Domain 오류로 변환
    private func mapFeedError(_ error: Error) -> FeedError {
        guard let dataError = error as? SupabaseDataError else {
            return .unknown // 예상하지 못한 외부 오류
        }

        switch dataError {
        case .network:
            return .networkUnavailable
        case .unauthorized:
            return .permissionDenied
        case .notFound:
            return .serverUnavailable // 피드 단일 조회가 추가되기 전까지 서버 응답 오류로 처리
        case .decoding:
            return .invalidFeedData
        case .database:
            return .serverUnavailable
        case .unknown:
            return .unknown
        }
    }
}

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
    
    init(datasource: FeedRemoteDataSourceProtocol) {
        self.datasource = datasource
    }
    
    // MARK: - 피드 목록 요약 조회
    func fetchFeeds(limit: Int) async throws -> [FeedEntity] {
        do {
            let feeds = try await datasource.fetchFeeds(
                memberCode: .jiheon,
                limit: limit
            ) // 원격 피드 DTO 목록 조회

            return try feeds.map { try $0.toEntity() } // Domain Entity 배열로 변환
        } catch let error as FeedError {
            throw error // DTO 변환에서 발생한 Domain 오류 유지
        } catch {
            throw mapFeedError(error) // Data 오류를 Feed Domain 오류로 변환
        }
    }

    // MARK: - 선택한 피드의 상세 미디어 조회
    func fetchFeedMedia(feedID: UUID) async throws -> [FeedImageEntity] {
        do {
            let media = try await datasource.fetchFeedMedia(feedID: feedID) // 원격 미디어 DTO 조회

            return try media
                .sorted { $0.sortOrder < $1.sortOrder }
                .map { try $0.toEntity() } // 표시 순서대로 Domain Entity 변환
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

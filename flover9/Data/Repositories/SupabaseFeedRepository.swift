//
//  SupabaseFeedRepository.swift
//  flover9
//
//  Created by 박선린 on 8/7/26.
//

// MARK: - 수파베이스에 저장된 피드 데이터를 가져오는 레퍼지토리
final class SupabaseFeedRepository: FeedRepositoryProtocol {
    // MARK: - DataSource
    private let datasource: FeedRemoteDataSource
    
    init(datasource: FeedRemoteDataSource) {
        self.datasource = datasource
    }
    
    func excute(limit: Int) async throws -> [FeedEntity] {
        let feeds: [FeedResponseDTO] = try await datasource.fetchFeeds(memberCode: .jiheon, limit: limit)
        return feeds.map { $0.toEntity()}
    }
    
    
}

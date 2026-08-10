//
//  FeedRemoteDataSource.swift
//  flover9
//
//  Created by 박선린 on 8/7/26.
//


protocol FeedRemoteDataSource {
    func fetchFeeds(
        memberCode: MemberCode,
        limit: Int
    ) async throws -> [FeedResponseDTO]
}

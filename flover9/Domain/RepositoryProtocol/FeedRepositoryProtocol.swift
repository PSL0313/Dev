//
//  FeedRepositoryProtocol.swift
//  Flover9
//
//  Created by 박선린 on 5/12/26.
//

import Foundation

protocol FeedRepositoryProtocol {
    func fetchFeeds(
        memberId: String?,
        source: FeedSource?,
        limit: Int?,
        offset: Int?
    ) async throws -> [FeedData]

    func getFeed(feedId: UUID) async throws -> FeedData
}

//
//  FeedRepositoryProtocol.swift
//  Flover9
//
//  Created by 박선린 on 5/12/26.
//

import Foundation

protocol FeedRepositoryProtocol {
    func fetchFeeds(limit: Int) async throws -> [FeedEntity]

    func fetchFeedMedia(feedID: UUID) async throws -> [FeedImageEntity]
}

//
//  FeedImageRow.swift
//  Flover9
//
//  Created by 박선린 on 5/12/26.
//

import Foundation

struct FeedImageRow: Codable, Identifiable {
    let feedId: UUID
    let imageURL: String
    let sortOrder: Int

    var id: String {
        "\(feedId.uuidString)-\(sortOrder)"
    }

    enum CodingKeys: String, CodingKey {
        case feedId = "feed_id"
        case imageURL = "image_url"
        case sortOrder = "sort_order"
    }
}

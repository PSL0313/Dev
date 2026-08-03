//
//  FeedMemberRow.swift
//  Flover9
//
//  Created by 박선린 on 5/12/26.
//

import Foundation

struct FeedMemberRow: Codable, Identifiable {
    let feedId: UUID
    let member: Member

    var id: String {
        "\(feedId.uuidString)-\(member.rawValue)"
    }

    enum CodingKeys: String, CodingKey {
        case feedId = "feed_id"
        case member
    }
}

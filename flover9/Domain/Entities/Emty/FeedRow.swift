//
//  FeedRow.swift
//  Flover9
//
//  Created by 박선린 on 5/12/26.
//

import Foundation

struct FeedRow: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let email: String
    let title: String
    let sourceName: String?
    let description: String?
    let captureDate: Date
    let uploadedAt: Date
    let source: FeedSource

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case email
        case title
        case sourceName = "source_name"
        case description
        case captureDate = "capture_date"
        case uploadedAt = "uploaded_at"
        case source
    }
}

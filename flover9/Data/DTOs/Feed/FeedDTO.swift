//
//  FeedDTO.swift
//  flover9
//
//  Created by 박선린 on 8/7/26.
//
import Foundation

struct FeedDTO: Decodable {
    let id: UUID
    let userId: UUID?
    let title: String?
    let sourceName: String?
    let description: String?
    let captureDate: Date
    let uploadedAt: Date
    let source: String
    let permalink: String

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case title
        case sourceName = "source_name"
        case description
        case captureDate = "capture_date"
        case uploadedAt = "uploaded_at"
        case source
        case permalink
    }
}

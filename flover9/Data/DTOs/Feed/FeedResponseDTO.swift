//
//  FeedResponseDTO.swift
//  flover9
//
//  Created by 박선린 on 8/7/26.
//
import Foundation

struct FeedResponseDTO: Decodable {
    let id: UUID
    let userId: UUID?
    let title: String?
    let sourceName: String?
    let description: String?
    let captureDate: Date
    let uploadedAt: Date
    let source: String
    let permalink: String

    let images: [FeedImageDTO]
    let feedMembers: [FeedMemberResponseDTO]

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

        case images = "feed_images"
        case feedMembers = "feed_members"
    }
}

extension FeedResponseDTO {

    func toEntity() -> FeedEntity {
        FeedEntity(
            id: id,
            title: title,
            sourceName: sourceName,
            description: description,
            captureDate: captureDate,
            source: source,
            permalink: permalink,

            images: images
                .sorted { $0.sortOrder < $1.sortOrder }
                .map { $0.toEntity() },

            members: feedMembers
                .map { $0.toEntity() }
        )
    }
}

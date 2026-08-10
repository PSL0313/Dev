//
//  FeedImageDTO.swift
//  flover9
//
//  Created by 박선린 on 8/7/26.
//
import Foundation

struct FeedImageDTO: Decodable {
    let id: UUID
    let feedId: UUID
    let imageUrl: String
    let sortOrder: Int
    let objectKey: String
    let contentType: String
    let fileSize: Int64
    let checksumSHA256: String?
    let etag: String?
    let uploadedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case feedId = "feed_id"
        case imageUrl = "image_url"
        case sortOrder = "sort_order"
        case objectKey = "object_key"
        case contentType = "content_type"
        case fileSize = "file_size"
        case checksumSHA256 = "checksum_sha256"
        case etag
        case uploadedAt = "uploaded_at"
    }
}

extension FeedImageDTO {
    func toEntity() -> FeedImageEntity {
        FeedImageEntity(
            id: self.id,
            feedId: self.feedId,
            imageURL: self.imageUrl,
            sortOrder: self.sortOrder,
            contentType: self.contentType,
        )
    }
}

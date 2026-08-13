//
//  FeedResponseDTO.swift
//  flover9
//
//  Created by 박선린 on 8/7/26.
//
import Foundation

// MARK: - 피드 목록에서 사용할 Supabase feeds 응답 DTO
nonisolated struct FeedResponseDTO: Decodable, Sendable {
    let id: UUID                               // feeds.id
    let userId: UUID?                         // feeds.user_id
    let title: String?                        // feeds.title
    let sourceName: String?                   // feeds.source_name
    let description: String?                  // feeds.description
    let captureDate: Date                     // feeds.capture_date
    let uploadedAt: Date                      // feeds.uploaded_at
    let source: String                        // feeds.source
    let permalink: String                     // feeds.permalink
    let thumbnailURL: String?                 // feeds.thumbnail_url
    let displayType: String                   // feeds.display_type
    let contentCount: Int                     // feeds.content_count

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
        case thumbnailURL = "thumbnail_url"
        case displayType = "display_type"
        case contentCount = "content_count"
    }
}

// MARK: - 피드 응답 DTO를 Domain Entity로 변환
extension FeedResponseDTO {
    nonisolated func toEntity() throws -> FeedEntity {
        guard let displayType = FeedDisplayType(rawValue: displayType) else {
            throw FeedError.invalidDisplayType             // 알 수 없는 표시 형식 차단
        }

        guard contentCount >= 0 else {
            throw FeedError.invalidContentCount             // 잘못된 콘텐츠 개수 차단
        }

        let thumbnailURL: URL?

        if let rawURL = self.thumbnailURL {
            guard let url = URL(string: rawURL) else {
                throw FeedError.invalidThumbnailURL         // 잘못된 대표 이미지 주소 차단
            }

            thumbnailURL = url
        } else {
            thumbnailURL = nil
        }

        return FeedEntity(
            id: id,
            title: title,
            sourceName: sourceName,
            description: description,
            captureDate: captureDate,
            source: source,
            permalink: permalink,
            thumbnailURL: thumbnailURL,
            displayType: displayType,
            contentCount: contentCount
        )
    }
}

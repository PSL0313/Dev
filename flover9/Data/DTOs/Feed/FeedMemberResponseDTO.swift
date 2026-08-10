//
//  FeedMemberResponseDTO.swift
//  flover9
//
//  Created by 박선린 on 8/7/26.
//
import Foundation

struct FeedMemberResponseDTO: Decodable {
    let id: UUID
    let feedId: UUID
    let memberCode: MemberCode

    enum CodingKeys: String, CodingKey {
        case id
        case feedId = "feed_id"
        case memberCode = "member"
    }
}

extension FeedMemberResponseDTO {
    func toEntity() -> FeedMemberEntity {
        FeedMemberEntity(id: self.id, feedId: self.feedId, memberCode: self.memberCode)
    }
}

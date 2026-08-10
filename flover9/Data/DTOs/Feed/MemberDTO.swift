//
//  MemberDTO.swift
//  flover9
//
//  Created by 박선린 on 8/7/26.
//
import Foundation

struct MemberDTO: Decodable {
    let code: String
    let displayName: String
    let sortOrder: Int
    let isActive: Bool
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case code
        case displayName = "display_name"
        case sortOrder = "sort_order"
        case isActive = "is_active"
        case createdAt = "created_at"
    }
}

extension MemberDTO {
    func toEntity() -> MemberEntity {
        return MemberEntity(code: code, displayName: displayName, sortOrder: sortOrder, isActive: isActive, createdAt: createdAt)
    }
}

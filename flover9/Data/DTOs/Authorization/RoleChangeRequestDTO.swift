//
//  RoleChangeRequestDTO.swift
//  flover9
//
//  Created by 박선린 on 9/29/26.
//

import Foundation

// 역할 변경 요청입니다. nil 역할도 누락하지 않고 JSON null로 보냅니다.
nonisolated struct RoleChangeRequestDTO: Encodable, Sendable {
    let action = "setRole" // 역할 부여·회수 작업
    let userID: UUID // 변경할 회원 ID
    let role: UserRole? // 변경 후 역할; nil은 회수
    let expectedRole: UserRole? // 목록에서 확인한 변경 전 역할
    let reason: String // 감사 이력에 남길 변경 사유
    enum CodingKeys: String, CodingKey {
        case action // 요청 종류
        case userID // 대상 회원
        case role // 새 역할
        case expectedRole // 예상 기존 역할
        case reason // 변경 사유
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(action, forKey: .action)
        try container.encode(userID, forKey: .userID)
        try container.encode(role, forKey: .role)
        try container.encode(expectedRole, forKey: .expectedRole)
        try container.encode(reason, forKey: .reason)
    }
}

//
//  RoleProfileDTO.swift
//  flover9
//
//  Created by 박선린 on 9/29/26.
//

import Foundation

// 역할 관리에 필요한 공개 프로필 표시 정보입니다. profiles.role은 읽지 않습니다.
nonisolated struct RoleProfileDTO: Decodable, Sendable {
    let id: UUID // 회원 프로필 ID
    let nickname: String? // 사용자 닉네임
}

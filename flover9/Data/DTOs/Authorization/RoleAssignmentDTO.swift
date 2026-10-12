//
//  RoleAssignmentDTO.swift
//  flover9
//
//  Created by 박선린 on 9/29/26.
//

import Foundation

// user_roles 테이블의 현재 역할 연결입니다.
nonisolated struct RoleAssignmentDTO: Decodable, Sendable {
    let user_id: UUID // 역할이 부여된 사용자 ID
    let role_code: UserRole // owner / admin / creator
}

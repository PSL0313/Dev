//
//  AuthorizationUseCaseProtocol.swift
//  flover9
//
//  Created by 박선린 on 9/29/26.
//

import Foundation

// 권한 조회와 역할 관리 규칙을 Presentation에 제공합니다.
@MainActor protocol AuthorizationUseCaseProtocol {
    func current() async throws -> UserAuthorization
    func members(query: String, offset: Int) async throws -> [RoleMember]
    func setRole(member: RoleMember, role: UserRole?, reason: String) async throws
    func transfer(to member: RoleMember, reason: String) async throws
}

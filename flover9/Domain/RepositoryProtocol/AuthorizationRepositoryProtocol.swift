//
//  AuthorizationRepositoryProtocol.swift
//  flover9
//
//  Created by 박선린 on 9/29/26.
//

import Foundation

// 프로필과 분리된 권한 조회 및 관리 저장소입니다.
@MainActor protocol AuthorizationRepositoryProtocol {
    func current() async throws -> UserAuthorization
    func members(query: String, offset: Int) async throws -> [RoleMember]
    func creators() async throws -> [RoleMember]
    func setRole(userID: UUID, role: UserRole?, expectedRole: UserRole?, reason: String) async throws
    func transfer(userID: UUID, reason: String) async throws
}

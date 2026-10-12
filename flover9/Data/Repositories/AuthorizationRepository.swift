//
//  AuthorizationRepository.swift
//  flover9
//
//  Created by 박선린 on 9/29/26.
//

import Foundation

// 원격 DTO를 Domain 모델로 바꾸고 역할 변경 요청을 구성합니다.
@MainActor final class AuthorizationRepository: AuthorizationRepositoryProtocol {
    nonisolated deinit {}
    private let source: AuthorizationRemoteDataSourceProtocol
    init(source: AuthorizationRemoteDataSourceProtocol) { self.source = source }
    func current() async throws -> UserAuthorization {
        let (userID, dto) = try await source.current()
        return try dto.entity(userID: userID)
    }
    func members(query: String, offset: Int) async throws -> [RoleMember] {
        try await source.members(query: query, offset: offset).map { $0.entity() }
    }
    func creators() async throws -> [RoleMember] { try await source.creators().map { $0.entity() } }
    func setRole(userID: UUID, role: UserRole?, expectedRole: UserRole?, reason: String) async throws {
        try await source.setRole(.init(userID: userID, role: role, expectedRole: expectedRole, reason: reason))
    }
    func transfer(userID: UUID, reason: String) async throws {
        try await source.transfer(.init(userID: userID, reason: reason))
    }
}

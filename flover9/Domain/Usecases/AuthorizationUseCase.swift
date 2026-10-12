//
//  AuthorizationUseCase.swift
//  flover9
//
//  Created by 박선린 on 9/29/26.
//

import Foundation

// 변경 직전에 권한을 새로 조회하고 역할 변경 범위·입력값을 검증합니다.
@MainActor final class AuthorizationUseCase: AuthorizationUseCaseProtocol {
    nonisolated deinit {}
    private let repository: AuthorizationRepositoryProtocol
    init(repository: AuthorizationRepositoryProtocol) { self.repository = repository }
    func current() async throws -> UserAuthorization { try await repository.current() }
    func members(query: String, offset: Int) async throws -> [RoleMember] {
        guard try await current().allows(.rolesRead) else { throw AuthorizationError.denied }
        return try await repository.members(query: query, offset: offset)
    }
    func setRole(member: RoleMember, role: UserRole?, reason: String) async throws {
        let reason = try validate(reason)
        guard try await current().canAssign(role, replacing: member.role) else { throw AuthorizationError.denied }
        try await repository.setRole(userID: member.id, role: role, expectedRole: member.role, reason: reason)
    }
    func transfer(to member: RoleMember, reason: String) async throws {
        let reason = try validate(reason)
        let authorization = try await current()
        guard authorization.role == .admin, authorization.allows(.rolesTransferAdmin), authorization.userID != member.id else {
            throw AuthorizationError.denied
        }
        try await repository.transfer(userID: member.id, reason: reason)
    }
    private func validate(_ reason: String) throws -> String {
        let reason = reason.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !reason.isEmpty, reason.count <= 500 else { throw AuthorizationError.invalidInput("변경 사유를 1~500자로 입력해 주세요.") }
        return reason
    }
}

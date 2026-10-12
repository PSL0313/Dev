//
//  AuthorizationRepositoryStub.swift
//  flover9Tests
//
//  Created by 박선린 on 9/29/26.
//

import Foundation
@testable import flover9

// 실제 계정 권한을 변경하지 않고 갱신·권한 회수·변경 요청을 검증하는 저장소입니다.
@MainActor final class AuthorizationRepositoryStub: AuthorizationRepositoryProtocol {
    nonisolated deinit {}
    var access = UserAuthorization(userID: UUID(), role: .creator, permissions: [.wallpaperCreate, .wallpaperManageOwn])
    var membersResult: [RoleMember] = []
    var currentError: Error?
    var mutationError: Error?
    private(set) var currentCalls = 0
    private(set) var changes: [(UUID, UserRole?, UserRole?, String)] = []
    private(set) var transfers: [UUID] = []
    func current() async throws -> UserAuthorization {
        currentCalls += 1
        if let currentError { throw currentError }
        return access
    }
    func members(query: String, offset: Int) async throws -> [RoleMember] { membersResult }
    func creators() async throws -> [RoleMember] { membersResult }
    func setRole(userID: UUID, role: UserRole?, expectedRole: UserRole?, reason: String) async throws {
        if let mutationError { throw mutationError }
        changes.append((userID, role, expectedRole, reason))
    }
    func transfer(userID: UUID, reason: String) async throws {
        if let mutationError { throw mutationError }
        transfers.append(userID)
        access = .init(userID: access.userID, role: .manager, permissions: [.rolesRead,.rolesManageCreator])
    }
}

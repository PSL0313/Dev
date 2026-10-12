//
//  AuthorizationTests.swift
//  flover9Tests
//
//  Created by 박선린 on 9/29/26.
//

import XCTest
@testable import flover9

// 프로필과 독립된 권한 판단, null 전달, 권한 회수 및 어드민 이전 범위를 검증합니다.
@MainActor final class AuthorizationTests: XCTestCase {
    func testRoleChangeEncodesExplicitNulls() throws {
        let request = RoleChangeRequestDTO(userID: UUID(), role: nil, expectedRole: nil, reason: "권한 회수")
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: JSONEncoder().encode(request)) as? [String: Any])
        XCTAssertTrue(object["role"] is NSNull)
        XCTAssertTrue(object["expectedRole"] is NSNull)
        XCTAssertNil(object["actorID"])
    }
    func testUnknownPermissionsDoNotGrantAccessAndUnknownRoleFails() throws {
        let id = UUID()
        let response = try JSONDecoder().decode(AuthorizationDTO.self, from: Data(#"{"role":null,"permissions":["future.permission"]}"#.utf8))
        XCTAssertFalse(try response.entity(userID: id).canOpenManagement)
        let unknown = AuthorizationDTO(role: "superadmin", permissions: ["roles.manage_manager"])
        XCTAssertThrowsError(try unknown.entity(userID: id))
    }
    func testProfileDecodingNoLongerDependsOnLegacyRole() throws {
        let data = Data(#"{"id":"10000000-0000-4000-8000-000000000001","nickname":"회원","role":"obsolete","profile_image_url":null,"created_at":"2026-09-29T00:00:00Z","updated_at":"2026-09-29T00:00:00Z"}"#.utf8)
        XCTAssertEqual(try JSONDecoder().decode(ReadUserProfileDTO.self, from: data).toEntity().nickname, "회원")
    }
    func testPermissionsNotRoleNameControlManagement() {
        let id = UUID()
        XCTAssertFalse(UserAuthorization(userID: id, role: .admin, permissions: []).canOpenManagement)
        XCTAssertTrue(UserAuthorization(userID: id, role: .creator, permissions: [.wallpaperManageOwn]).canManageWallpapers)
        let admin = UserAuthorization(userID: id, role: .manager, permissions: [.rolesManageCreator])
        XCTAssertTrue(admin.canAssign(.creator, replacing: nil))
        XCTAssertTrue(admin.canAssign(nil, replacing: .creator))
        XCTAssertFalse(admin.canAssign(.manager, replacing: .creator))
        XCTAssertFalse(admin.canAssign(nil, replacing: .manager))
        XCTAssertFalse(admin.canAssign(.creator, replacing: .admin))
    }
    func testLatestPermissionRequiredForEveryMutation() async throws {
        let repository = AuthorizationRepositoryStub()
        repository.access = .init(userID: UUID(), role: .manager, permissions: [.rolesRead,.rolesManageCreator])
        let useCase = AuthorizationUseCase(repository: repository)
        let member = RoleMember(id: UUID(), nickname: "회원", role: nil)
        try await useCase.setRole(member: member, role: .creator, reason: "  등록  ")
        XCTAssertEqual(repository.changes.count, 1)
        XCTAssertNil(repository.changes[0].2)
        XCTAssertEqual(repository.changes[0].3, "등록")
        repository.access = .init(userID: repository.access.userID, role: nil, permissions: [])
        do { try await useCase.setRole(member: member, role: .creator, reason: "재시도"); XCTFail("Revoked permission must fail") }
        catch { XCTAssertEqual(error as? AuthorizationError, .denied) }
        XCTAssertEqual(repository.currentCalls, 2)
        XCTAssertEqual(repository.changes.count, 1)
    }
    func testAdminCannotAppointOrDemoteAdmin() async throws {
        let repository = AuthorizationRepositoryStub()
        repository.access = .init(userID: UUID(), role: .manager, permissions: [.rolesManageCreator])
        let useCase = AuthorizationUseCase(repository: repository)
        for (before, after) in [(nil, UserRole.manager), (UserRole.manager, nil)] {
            do { try await useCase.setRole(member: .init(id: UUID(), nickname: nil, role: before), role: after, reason: "시도"); XCTFail("Must deny") }
            catch { XCTAssertEqual(error as? AuthorizationError, .denied) }
        }
        XCTAssertTrue(repository.changes.isEmpty)
    }
    func testOwnerTransferDemotesAndCannotBeRepeated() async throws {
        let repository = AuthorizationRepositoryStub()
        repository.access = .init(userID: UUID(), role: .admin, permissions: [.rolesRead,.rolesTransferAdmin,.rolesManageManager])
        let useCase = AuthorizationUseCase(repository: repository)
        let target = RoleMember(id: UUID(), nickname: "새 어드민", role: .manager)
        try await useCase.transfer(to: target, reason: "운영 인계")
        do { try await useCase.transfer(to: target, reason: "재시도"); XCTFail("Former owner must be denied") }
        catch { XCTAssertEqual(error as? AuthorizationError, .denied) }
        XCTAssertEqual(repository.transfers, [target.id])
    }
    func testOwnerCannotTransferToSelfAndReasonRequired() async throws {
        let repository = AuthorizationRepositoryStub()
        repository.access = .init(userID: UUID(), role: .admin, permissions: [.rolesTransferAdmin])
        let useCase = AuthorizationUseCase(repository: repository)
        do { try await useCase.transfer(to: .init(id: repository.access.userID, nickname: nil, role: .admin), reason: "동일 계정"); XCTFail() }
        catch { XCTAssertEqual(error as? AuthorizationError, .denied) }
        do { try await useCase.transfer(to: .init(id: UUID(), nickname: nil, role: nil), reason: "   "); XCTFail() }
        catch { guard case AuthorizationError.invalidInput = error else { return XCTFail() } }
        XCTAssertTrue(repository.transfers.isEmpty)
    }
    func testConflictIsNotRetriedAutomatically() async throws {
        let repository = AuthorizationRepositoryStub()
        repository.access = .init(userID: UUID(), role: .manager, permissions: [.rolesManageCreator])
        repository.mutationError = AuthorizationError.conflict
        do { try await AuthorizationUseCase(repository: repository).setRole(member: .init(id: UUID(), nickname: nil, role: nil), role: .creator, reason: "등록"); XCTFail() }
        catch { XCTAssertEqual(error as? AuthorizationError, .conflict) }
        XCTAssertEqual(repository.currentCalls, 1)
    }
    func testRevokedListAccessClearsVisibleMembers() async throws {
        let repository = AuthorizationRepositoryStub()
        repository.access = .init(userID: UUID(), role: .manager, permissions: [.rolesRead])
        repository.membersResult = [.init(id: UUID(), nickname: "회원", role: nil)]
        let model = RoleManagementViewModel(useCase: AuthorizationUseCase(repository: repository))
        let loaded = expectation(description: "Loaded")
        model.onChange = { if !model.isLoading { loaded.fulfill() } }
        model.load()
        await fulfillment(of: [loaded], timeout: 3)
        XCTAssertEqual(model.members.count, 1)
        repository.access = .init(userID: repository.access.userID, role: nil, permissions: [])
        let denied = expectation(description: "Revoked")
        model.onChange = { if !model.isLoading { denied.fulfill() } }
        model.load()
        await fulfillment(of: [denied], timeout: 3)
        model.onChange = nil
        XCTAssertTrue(model.members.isEmpty)
        XCTAssertNil(model.access)
        XCTAssertNotNil(model.message)
    }
}

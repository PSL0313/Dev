//
//  SupabaseAuthorizationRemoteDataSource.swift
//  flover9
//
//  Created by 박선린 on 9/29/26.
//

import Foundation
import Supabase

// 사용자 JWT로 권한 Edge Function과 RLS가 적용된 회원·역할 목록을 조회합니다.
@MainActor final class SupabaseAuthorizationRemoteDataSource: AuthorizationRemoteDataSourceProtocol {
    nonisolated deinit {}
    private let client: SupabaseClient
    init(client: SupabaseClient) { self.client = client }

    func current() async throws -> (UUID, AuthorizationDTO) {
        let session = try await client.auth.session
        let response: AuthorizationDTO = try await invoke(body: ["action": "me"], token: session.accessToken)
        guard try await client.auth.session.user.id == session.user.id else { throw AuthorizationError.sessionExpired }
        return (session.user.id, response)
    }
    func members(query: String, offset: Int) async throws -> [RoleMemberDTO] {
        let request = client.from("profiles").select("id,nickname")
        let text = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if let id = UUID(uuidString: text) { _ = request.eq("id", value: id) }
        else if !text.isEmpty {
            let escaped = text.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "%", with: "\\%").replacingOccurrences(of: "_", with: "\\_")
            _ = request.ilike("nickname", pattern: "%\(escaped)%")
        }
        let profiles: [RoleProfileDTO] = try await request.order("id").range(from: offset, to: offset + 49).execute().value
        guard !profiles.isEmpty else { return [] }
        let roles: [RoleAssignmentDTO] = try await client.from("user_roles").select("user_id,role_code")
            .in("user_id", values: profiles.map(\.id)).execute().value
        let assignments = Dictionary(uniqueKeysWithValues: roles.map { ($0.user_id, $0.role_code) })
        return profiles.map { .init(profile: $0, role: assignments[$0.id]) }
    }
    func creators() async throws -> [RoleMemberDTO] {
        var result: [RoleMemberDTO] = []
        var offset = 0
        while true {
            try Task.checkCancellation()
            let roles: [RoleAssignmentDTO] = try await client.from("user_roles").select("user_id,role_code")
                .in("role_code", values: ["admin", "manager", "creator"]).order("user_id")
                .range(from: offset, to: offset + 99).execute().value
            guard !roles.isEmpty else { break }
            let profiles: [RoleProfileDTO] = try await client.from("profiles").select("id,nickname")
                .in("id", values: roles.map(\.user_id)).execute().value
            let assignments = Dictionary(uniqueKeysWithValues: roles.map { ($0.user_id, $0.role_code) })
            result += profiles.map { .init(profile: $0, role: assignments[$0.id]) }
            if roles.count < 100 { break }; offset += roles.count
        }
        return result.sorted { ($0.profile.nickname ?? "") < ($1.profile.nickname ?? "") }
    }
    func setRole(_ request: RoleChangeRequestDTO) async throws {
        let _: [String: AnyJSON] = try await invoke(body: request)
    }
    func transfer(_ request: OwnershipTransferRequestDTO) async throws {
        let _: [String: AnyJSON] = try await invoke(body: request)
    }
    private func invoke<Body: Encodable & Sendable, Response: Decodable & Sendable>(body: Body, token: String? = nil) async throws -> Response {
        do {
            let accessToken: String
            if let token { accessToken = token } else { accessToken = try await client.auth.session.accessToken }
            return try await client.functions.invoke("authorization", options: FunctionInvokeOptions(
                headers: ["Authorization": "Bearer \(accessToken)"], body: body))
        } catch let error as FunctionsError {
            if case .httpError(let code, _) = error {
                switch code {
                case 401: throw AuthorizationError.sessionExpired
                case 403: throw AuthorizationError.denied
                case 409: throw AuthorizationError.conflict
                case 400: throw AuthorizationError.invalidInput("대상 회원과 변경 사유를 확인해 주세요.")
                default: break
                }
            }
            throw AuthorizationError.unavailable
        }
    }
}

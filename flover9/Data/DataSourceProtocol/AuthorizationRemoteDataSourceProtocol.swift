//
//  AuthorizationRemoteDataSourceProtocol.swift
//  flover9
//
//  Created by 박선린 on 9/29/26.
//

import Foundation

// 권한 API와 역할 목록 조회의 원격 경계입니다.
@MainActor protocol AuthorizationRemoteDataSourceProtocol {
    func current() async throws -> (UUID, AuthorizationDTO)
    func members(query: String, offset: Int) async throws -> [RoleMemberDTO]
    func creators() async throws -> [RoleMemberDTO]
    func setRole(_ request: RoleChangeRequestDTO) async throws
    func transfer(_ request: OwnershipTransferRequestDTO) async throws
}

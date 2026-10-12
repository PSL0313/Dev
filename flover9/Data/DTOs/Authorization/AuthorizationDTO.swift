//
//  AuthorizationDTO.swift
//  flover9
//
//  Created by 박선린 on 9/29/26.
//

import Foundation

// authorization / me 응답을 앱의 권한 모델로 변환합니다.
nonisolated struct AuthorizationDTO: Decodable, Sendable {
    let role: String? // 서버 역할 코드; 일반 회원은 null
    let permissions: [String] // 작업별 권한 코드 배열
    func entity(userID: UUID) throws -> UserAuthorization {
        let mappedRole = role.flatMap(UserRole.init(rawValue:))
        guard role == nil || mappedRole != nil else { throw AuthorizationError.unavailable }
        return .init(userID: userID, role: mappedRole, permissions: Set(permissions.compactMap(AppPermission.init(rawValue:))))
    }
}

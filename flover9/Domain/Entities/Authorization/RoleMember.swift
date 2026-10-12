//
//  RoleMember.swift
//  flover9
//
//  Created by 박선린 on 9/29/26.
//

import Foundation

// 역할 관리 목록에 표시할 회원과 마지막으로 조회한 역할입니다.
nonisolated struct RoleMember: Sendable, Equatable, Identifiable {
    let id: UUID // 대상 profiles.id와 auth.users.id
    let nickname: String? // 아직 설정하지 않은 회원은 nil
    let role: UserRole? // expectedRole에 전달할 기존 역할; 일반 회원은 nil
    var displayName: String {
        guard let nickname, !nickname.isEmpty else { return "닉네임 미설정" }
        return nickname
    }
    var roleTitle: String { role?.title ?? "일반 회원" }
}

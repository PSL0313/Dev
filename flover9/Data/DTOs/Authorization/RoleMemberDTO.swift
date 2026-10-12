//
//  RoleMemberDTO.swift
//  flover9
//
//  Created by 박선린 on 9/29/26.
//

// 프로필 표시 정보와 권한 테이블 조회 결과를 합친 전달 모델입니다.
nonisolated struct RoleMemberDTO: Sendable {
    let profile: RoleProfileDTO // 회원 표시 정보
    let role: UserRole? // 권한 테이블에 행이 없으면 일반 회원
    func entity() -> RoleMember { .init(id: profile.id, nickname: profile.nickname, role: role) }
}

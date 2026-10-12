//
//  ManagementIdentity.swift
//  flover9
//
//  Created by 박선린 on 9/29/26.
//

// 관리자 홈에 표시할 프로필과 별도로 조회한 실제 권한입니다.
nonisolated struct ManagementIdentity: Sendable {
    let profile: UserProfile // 이름과 이미지 등 표시 정보
    let authorization: UserAuthorization // 기능별 접근 허용 여부
}

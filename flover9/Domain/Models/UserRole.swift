//
//  UserRole.swift
//  flover9
//
//  Created by 박선린 on 9/29/26.
//

// 서버의 user_roles에 저장하는 운영 역할입니다. 일반 회원은 역할이 nil입니다.
nonisolated enum UserRole: String, Codable, Sendable, CaseIterable {
    case admin // 운영 책임자; 매니저 임명과 소유권 이전 가능
    case manager // 전체 콘텐츠 및 크리에이터 역할 관리
    case creator // 본인 콘텐츠 제작과 관리

    var title: String {
        switch self {
        case .admin: "어드민"
        case .manager: "매니저"
        case .creator: "크리에이터"
        }
    }
}

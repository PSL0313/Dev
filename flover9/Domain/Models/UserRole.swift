//
//  UserRole.swift
//  flover9
//
//  Created by 박선린 on 7/29/26.
//

// MARK: - 서비스 내 사용자의 권한
nonisolated enum UserRole: String, Sendable, Equatable {
    case user       // 일반 사용자
    case blogger    // 블로거
    case homema     // 홈마
    case manager    // 운영 관리자
    case admin      // 최고 관리자
}

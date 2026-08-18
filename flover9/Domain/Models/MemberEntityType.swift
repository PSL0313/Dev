//
//  MemberEntityType.swift
//  flover9
//
//  Created by 박선린 on 8/10/26.
//

// MARK: - members 테이블의 행이 나타내는 대상 분류
nonisolated enum MemberEntityType: String, Codable, Sendable, Equatable {
    case member      // 그룹 멤버
    case official    // 공식 계정 또는 공식 채널
}

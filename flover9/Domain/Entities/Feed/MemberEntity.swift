//
//  MemberEntity.swift
//  flover9
//
//  Created by 박선린 on 8/7/26.
//
import Foundation

// MARK: - 앱의 화면과 비즈니스 로직에서 사용하는 멤버 정보
struct MemberEntity: Identifiable, Equatable, Sendable, Hashable {
    var id: String { code }                 // 멤버 코드를 안정적인 식별자로 사용

    let code: String                        // 서버에서 사용하는 멤버 코드
    let displayName: String                 // 화면에 표시할 이름
    let sortOrder: Int                      // 멤버 정렬 순서
    let isActive: Bool                      // 현재 서비스 노출 여부
    let createdAt: Date                     // 데이터 생성 시각
    let entityType: MemberEntityType        // 멤버 데이터 분류
    let profileImageURL: URL?               // 프로필 이미지 주소
}

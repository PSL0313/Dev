//
//  UpdateUserProfileDTO.swift
//  flover9
//
//  Created by 박선린 on 7/29/26.
//
import Foundation

// MARK: - Supabase에 전달할 사용자 프로필 수정 정보
nonisolated struct UpdateUserProfileDTO: Encodable, Sendable {
    let nickname: String?          // 변경할 사용자 닉네임
    let profileImageURL: String?   // 변경할 프로필 이미지 주소

    // MARK: - profiles 테이블의 실제 열 이름
    enum CodingKeys: String, CodingKey {
        case nickname                               // nickname 열
        case profileImageURL = "profile_image_url" // profile_image_url 열
    }
}

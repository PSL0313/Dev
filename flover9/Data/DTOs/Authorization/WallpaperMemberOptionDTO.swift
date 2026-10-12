//
//  WallpaperMemberOptionDTO.swift
//  flover9
//
//  Created by 박선린 on 9/29/26.
//

// 배경화면 편집에서 선택 가능한 활성 멤버 정보입니다.
nonisolated struct WallpaperMemberOptionDTO: Decodable, Sendable {
    let code: String // 멤버 고유 코드
    let display_name: String // 선택지 표시 이름
}

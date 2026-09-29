//
//  WallpaperSeriesDTO.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Foundation

// 시리즈 조회 응답과 제작자 프로필 정보를 도메인 엔티티로 변환합니다.
struct WallpaperSeriesDTO: Decodable {
    let id: UUID // 시리즈 고유 식별자
    let title: String // 시리즈 제목; 저장 시 1~120자 필수
    let creatorID: UUID // 제작자의 profiles.id를 참조하는 식별자
    let category: WallpaperCategory // 시리즈의 배경화면 분류
    let coverURL: URL? // 시리즈 대표 이미지 주소
    let isFeatured: Bool // 추천 시리즈로 노출할지 여부
    let isPublished: Bool // 일반 사용자에게 공개할지 여부
    let createdAt: Date // 생성된 시각
    let description: String // 시리즈 소개 문구
    let creatorName: String // 제작자 닉네임; 서버는 닉네임이 비어 있으면 Creator를 반환
    let wallpaperCount: Int // 시리즈에 속한 배경화면 개수
    let revision: Int // 서버의 현재 수정 버전; 변경 충돌 검사에 사용
    let creatorProfileImageURL: URL? // 제작자 프로필 사진 주소; 없으면 기본 아이콘 표시

    // Swift 프로퍼티 이름과 서버 JSON 필드 이름의 대응을 정의합니다.
    enum CodingKeys: String, CodingKey {
        case id // JSON id 필드: 항목을 구분하는 고유 식별자
        case title // JSON title 필드: 화면에 표시할 이름
        case category // JSON category 필드: 시리즈의 배경화면 분류
        case description // JSON description 필드: 시리즈 소개 문구
        case revision // JSON revision 필드: 서버의 현재 수정 버전
        case creatorName = "creator_name" // JSON creator_name 필드: 제작자 닉네임; 서버는 닉네임이 비어 있으면 Creator를 반환
        case creatorProfileImageURL = "creator_profile_image_url" // JSON creator_profile_image_url 필드: 제작자 프로필 사진 주소; 없으면 기본 아이콘 표시
        case wallpaperCount = "wallpaper_count" // JSON wallpaper_count 필드: 시리즈에 속한 배경화면 개수
        case creatorID = "creator_id" // JSON creator_id 필드: 제작자의 profiles.id를 참조하는 식별자
        case coverURL = "cover_url" // JSON cover_url 필드: 시리즈 대표 이미지 주소
        case isFeatured = "is_featured" // JSON is_featured 필드: 추천 시리즈로 노출할지 여부
        case isPublished = "is_published" // JSON is_published 필드: 일반 사용자에게 공개할지 여부
        case createdAt = "created_at" // JSON created_at 필드: 생성된 시각
    }

    func entity() -> WallpaperSeriesEntity {
        .init(
            id: id, title: title, creatorID: creatorID, category: category,
            coverURL: coverURL, isFeatured: isFeatured, isPublished: isPublished, createdAt: createdAt,
            description: description, creatorName: creatorName, wallpaperCount: wallpaperCount, revision: revision,
            creatorProfileImageURL: creatorProfileImageURL)
    }
}

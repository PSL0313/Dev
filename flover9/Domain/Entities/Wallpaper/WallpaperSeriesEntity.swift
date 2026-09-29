//
//  WallpaperSeriesEntity.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Foundation

// 시리즈의 대표 이미지, 제작자 프로필, 공개 상태와 배경화면 개수를 담습니다.
struct WallpaperSeriesEntity: Identifiable, Equatable {
    let id: UUID // 시리즈 고유 식별자
    let title: String // 시리즈 제목; 저장 시 1~120자 필수
    let creatorID: UUID // 제작자의 profiles.id를 참조하는 식별자
    let category: WallpaperCategory // 시리즈의 배경화면 분류
    let coverURL: URL? // 시리즈 대표 이미지 주소
    let isFeatured: Bool // 추천 시리즈로 노출할지 여부
    let isPublished: Bool // 일반 사용자에게 공개할지 여부
    let createdAt: Date // 생성된 시각
    var description = "" // 시리즈 소개 문구
    var creatorName = "Creator" // 제작자 프로필에서 조회한 닉네임; 기본값은 Creator
    var wallpaperCount = 0 // 시리즈에 속한 배경화면 개수
    var revision = 1 // 서버의 현재 수정 버전; 변경 충돌 검사에 사용
    var creatorProfileImageURL: URL? = nil // 제작자 프로필 사진 주소; 없으면 기본 아이콘 표시
}

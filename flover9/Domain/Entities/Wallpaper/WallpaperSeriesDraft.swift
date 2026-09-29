//
//  WallpaperSeriesDraft.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Foundation

// 시리즈 제목·제작자·공개 설정과 새 대표 이미지를 편집하는 모델입니다.
struct WallpaperSeriesDraft {
    let id: UUID // 시리즈 고유 식별자
    var title: String // 시리즈 제목; 저장 시 1~120자 필수
    var creatorID: UUID // 제작자의 profiles.id를 참조하는 식별자
    var category: WallpaperCategory // 시리즈의 배경화면 분류
    var isFeatured: Bool // 추천 시리즈로 노출할지 여부
    var isPublished: Bool // 일반 사용자에게 공개할지 여부
    var cover: WallpaperImageFile? // 새로 선택한 대표 이미지; 수정 시 nil이면 기존 이미지 유지
    var description = "" // 시리즈 소개 문구
    var revision: Int? // 현재 서버 수정 버전; 신규 편집의 nil은 아직 저장되지 않았음을 의미
    var requestID = UUID() // 같은 저장 요청의 재시도를 식별하여 중복 처리를 방지하는 값
}

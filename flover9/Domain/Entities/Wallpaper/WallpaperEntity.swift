//
//  WallpaperEntity.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Foundation

// 시리즈에 속한 개별 배경화면의 목업·원본 주소와 검색·표시 정보를 담습니다.
struct WallpaperEntity: Identifiable, Equatable, Codable {
    let id: UUID // 개별 배경화면 고유 식별자
    let seriesID: UUID // 소속 또는 작업 대상 시리즈의 식별자
    let mockupURL: URL? // 목록과 큰 미리보기에 사용할 썸네일·목업 주소
    let originalURL: URL? // 실제 다운로드할 원본 이미지 주소
    let sortOrder: Int // 시리즈 안의 표시 순서로, 작은 값이 먼저 표시됨
    let seriesTitle: String // 소속 시리즈의 제목
    let category: WallpaperCategory // 시리즈의 배경화면 분류
    let creatorID: UUID // 제작자의 profiles.id를 참조하는 식별자
    let memberCodes: [String] // 연결된 멤버 코드 목록
    var displayLabel: String { "\(seriesTitle) · \(category.title)" } // 개별 제목 대신 시리즈명과 카테고리로 만든 표시 문구
    var creatorName = "Creator" // 제작자 프로필에서 조회한 닉네임; 기본값은 Creator
    var revision = 1 // 서버의 현재 수정 버전; 변경 충돌 검사에 사용
}

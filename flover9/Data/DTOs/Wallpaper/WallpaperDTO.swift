//
//  WallpaperDTO.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Foundation

// 배경화면 조회 응답을 해석하고 도메인 엔티티로 변환합니다.
struct WallpaperDTO: Decodable {
    let id: UUID // 개별 배경화면 고유 식별자
    let seriesID: UUID // 소속 또는 작업 대상 시리즈의 식별자
    let mockupURL: URL? // 목록과 큰 미리보기에 사용할 썸네일·목업 주소
    let originalURL: URL? // 실제 다운로드할 원본 이미지 주소
    let sortOrder: Int // 시리즈 안의 표시 순서로, 작은 값이 먼저 표시됨
    let seriesTitle: String // 소속 시리즈의 제목
    let category: WallpaperCategory // 시리즈의 배경화면 분류
    let creatorID: UUID // 제작자의 profiles.id를 참조하는 식별자
    let memberCodes: [String] // 연결된 멤버 코드 목록
    let creatorName: String // 제작자 닉네임; 서버는 닉네임이 비어 있으면 Creator를 반환
    let revision: Int // 서버의 현재 수정 버전; 변경 충돌 검사에 사용

    // Swift 프로퍼티 이름과 서버 JSON 필드 이름의 대응을 정의합니다.
    enum CodingKeys: String, CodingKey {
        case id // JSON id 필드: 항목을 구분하는 고유 식별자
        case category // JSON category 필드: 시리즈의 배경화면 분류
        case revision // JSON revision 필드: 서버의 현재 수정 버전
        case creatorName = "creator_name" // JSON creator_name 필드: 제작자 닉네임; 서버는 닉네임이 비어 있으면 Creator를 반환
        case seriesID = "series_id" // JSON series_id 필드: 소속 또는 작업 대상 시리즈의 식별자
        case mockupURL = "mockup_url" // JSON mockup_url 필드: 목록과 큰 미리보기에 사용할 썸네일·목업 주소
        case originalURL = "original_url" // JSON original_url 필드: 실제 다운로드할 원본 이미지 주소
        case sortOrder = "sort_order" // JSON sort_order 필드: 시리즈 안의 표시 순서로, 작은 값이 먼저 표시됨
        case seriesTitle = "series_title" // JSON series_title 필드: 소속 시리즈의 제목
        case creatorID = "creator_id" // JSON creator_id 필드: 제작자의 profiles.id를 참조하는 식별자
        case memberCodes = "member_codes" // JSON member_codes 필드: 연결된 멤버 코드 목록
    }

    func entity() -> WallpaperEntity {
        .init(
            id: id, seriesID: seriesID, mockupURL: mockupURL,
            originalURL: originalURL, sortOrder: sortOrder, seriesTitle: seriesTitle,
            category: category, creatorID: creatorID, memberCodes: memberCodes, creatorName: creatorName,
            revision: revision)
    }
}

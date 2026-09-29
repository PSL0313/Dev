//
//  WallpaperDraft.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Foundation

// 개별 배경화면의 편집 값과 새로 선택한 이미지, 저장 재시도 식별자를 보관합니다.
struct WallpaperDraft {
    let id: UUID // 개별 배경화면 고유 식별자
    let seriesID: UUID // 소속 또는 작업 대상 시리즈의 식별자
    var sortOrder: Int // 시리즈 안의 표시 순서로, 작은 값이 먼저 표시됨
    var memberCodes: [String] // 연결된 멤버 코드 목록
    var mockup: WallpaperImageFile? // 새로 선택한 목업 파일; 수정 시 nil이면 기존 이미지 유지
    var original: WallpaperImageFile? // 새로 선택한 원본 파일; 수정 시 nil이면 기존 이미지 유지
    var revision: Int? // 현재 서버 수정 버전; 신규 편집의 nil은 아직 저장되지 않았음을 의미
    var requestID = UUID() // 같은 저장 요청의 재시도를 식별하여 중복 처리를 방지하는 값
}

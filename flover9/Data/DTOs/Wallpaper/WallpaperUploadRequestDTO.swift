//
//  WallpaperUploadRequestDTO.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Foundation
import Supabase

// 이미지 업로드 URL 발급 또는 업로드 완료 검증을 요청합니다.
struct WallpaperUploadRequestDTO: Encodable {
    let action: String // Edge Function에서 수행할 작업 이름
    let ticketID: UUID // 이미지 업로드 작업을 식별하는 서버 티켓 ID
    var seriesID: UUID? // 소속 또는 작업 대상 시리즈의 식별자
    var wallpaperID: UUID? // 업로드할 개별 배경화면 ID; 시리즈 대표 이미지는 nil
    var slot: String? // 이미지 용도(cover: 대표, mockup: 목업, original: 원본)
    var contentType: String? // 파일 MIME 형식(image/jpeg, image/png, image/webp)
    var fileSizeBytes: Int? // 선택한 이미지의 바이트 단위 크기
    var fileName: String? // 업로드 요청에 전달할 확장자 포함 파일명
}

//
//  WallpaperCommitDTO.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Foundation
import Supabase

// 시리즈·배경화면 저장 또는 삭제를 서버에 요청하는 공통 본문입니다.
struct WallpaperCommitDTO<Payload: Encodable>: Encodable {
    let action: String // Edge Function에서 수행할 작업 이름
    let requestID: UUID // 같은 저장 요청의 재시도를 식별하여 중복 처리를 방지하는 값
    let id: UUID // 저장·삭제 대상 시리즈 또는 배경화면의 식별자
    let seriesID: UUID // 소속 또는 작업 대상 시리즈의 식별자
    let expectedRevision: Int? // 수정·삭제 충돌 확인용 서버 버전; 신규 생성은 nil
    let payload: Payload // 해당 작업에서 저장할 편집 값
    let ticketIDs: [UUID] // 검증을 마쳐 이번 저장에 연결할 이미지 업로드 티켓 목록
}

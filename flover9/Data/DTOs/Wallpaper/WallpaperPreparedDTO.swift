//
//  WallpaperPreparedDTO.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Foundation
import Supabase

// 업로드 파일 검증이 완료되어 저장에 사용할 수 있는지 확인하는 응답입니다.
nonisolated struct WallpaperPreparedDTO: Decodable, Sendable {
    let ticketID: UUID // 이미지 업로드 작업을 식별하는 서버 티켓 ID
    let prepared: Bool // 서버에서 파일 검증을 마쳐 저장에 사용할 수 있는지 여부
}

//
//  WallpaperFieldsDTO.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Foundation
import Supabase

// 개별 배경화면 저장 시 정렬 순서와 연결할 멤버를 전송합니다.
struct WallpaperFieldsDTO: Encodable {
    let sort_order: Int // 시리즈 안의 표시 순서로, 작은 값이 먼저 표시됨
    let member_codes: [String] // 연결된 멤버 코드 목록
}

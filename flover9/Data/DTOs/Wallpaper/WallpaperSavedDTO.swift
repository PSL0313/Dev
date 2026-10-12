//
//  WallpaperSavedDTO.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Foundation
import Supabase

// 시리즈·배경화면 변경이 서버에 반영되었는지 확인하는 응답입니다.
nonisolated struct WallpaperSavedDTO: Decodable, Sendable {
    let saved: Bool // 서버에서 변경 내용을 저장했는지 여부
}

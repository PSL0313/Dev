//
//  WallpaperSignedDTO.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Foundation
import Supabase

// R2 업로드용 임시 URL과 PUT 요청에 필요한 헤더를 받습니다.
struct WallpaperSignedDTO: Decodable {
    let uploadURL: URL // 만료 시간이 있는 R2 업로드용 서명 URL
    let requiredHeaders: [String: String] // 서명된 PUT 업로드에 함께 보내야 하는 HTTP 헤더
}

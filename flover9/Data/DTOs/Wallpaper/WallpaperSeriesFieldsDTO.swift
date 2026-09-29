//
//  WallpaperSeriesFieldsDTO.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Foundation
import Supabase

// 시리즈 저장 시 제목·설명·제작자·분류·공개 설정을 전송합니다.
struct WallpaperSeriesFieldsDTO: Encodable {
    let title: String // 시리즈 제목; 저장 시 1~120자 필수
    let description: String // 시리즈 소개 문구
    let creator_id: UUID // 제작자의 profiles.id를 참조하는 식별자
    let category: String // 시리즈의 배경화면 분류
    let is_featured: Bool // 추천 시리즈로 노출할지 여부
    let is_published: Bool // 일반 사용자에게 공개할지 여부
}

//
//  WallpaperEditorContext.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Foundation

// 현재 편집자의 권한과 선택 가능한 제작자·멤버 목록을 전달합니다.
struct WallpaperEditorContext {
    let userID: UUID // 현재 로그인한 편집자의 profiles.id
    let canFeature: Bool // 추천 시리즈 설정을 변경할 수 있는지 여부
    var canManageAny: Bool = false // 타인 시리즈까지 조회·수정할 수 있는지 여부
    var canCreate: Bool = false // 새 시리즈 생성 권한
    var canAssignCreator: Bool = false // 제작자 변경 권한
    let creators: [WallpaperChoice] // 선택 가능한 제작자 목록
    let members: [WallpaperChoice] // 선택 가능한 멤버 목록
}

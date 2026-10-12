//
//  AppPermission.swift
//  flover9
//
//  Created by 박선린 on 9/29/26.
//

// 서버가 반환하는 작업별 권한 코드입니다. 역할 이름으로 권한을 추측하지 않습니다.
nonisolated enum AppPermission: String, Sendable, CaseIterable {
    case feedCreate = "feed.create" // 피드 생성
    case feedManageOwn = "feed.manage_own" // 본인 피드 수정·삭제
    case feedManageAny = "feed.manage_any" // 전체 피드 관리
    case scheduleManage = "schedule.manage" // 일정과 행사 관리
    case membersManage = "members.manage" // 멤버 정보 관리
    case mediaCleanup = "media.cleanup" // 미디어 정리 재시도
    case wallpaperCreate = "wallpaper.create" // 배경화면 시리즈 생성
    case wallpaperManageOwn = "wallpaper.manage_own" // 본인 시리즈 관리
    case wallpaperManageAny = "wallpaper.manage_any" // 전체 시리즈 관리
    case wallpaperFeature = "wallpaper.feature" // 추천 시리즈 설정
    case wallpaperAssignCreator = "wallpaper.assign_creator" // 제작자 지정·변경
    case rolesRead = "roles.read" // 회원 역할 및 이력 조회
    case rolesManageCreator = "roles.manage_creator" // 크리에이터 임명·회수
    case rolesManageManager = "roles.manage_manager" // 매니저 임명·회수
    case rolesTransferAdmin = "roles.transfer_admin" // 어드민 이전
}

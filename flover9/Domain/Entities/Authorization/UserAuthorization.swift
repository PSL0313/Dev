//
//  UserAuthorization.swift
//  flover9
//
//  Created by 박선린 on 9/29/26.
//

import Foundation

// 한 번의 서버 조회로 확인한 계정과 권한입니다. 영구 캐시에 저장하지 않습니다.
nonisolated struct UserAuthorization: Sendable, Equatable {
    let userID: UUID // 조회에 사용한 사용자 세션 ID
    let role: UserRole? // 일반 회원은 nil
    let permissions: Set<AppPermission> // 서버에서 부여한 작업 권한

    func allows(_ permission: AppPermission) -> Bool { permissions.contains(permission) }
    var canManageWallpapers: Bool {
        allows(.wallpaperCreate) || allows(.wallpaperManageOwn) || allows(.wallpaperManageAny)
    }
    var canOpenManagement: Bool {
        allows(.feedManageAny) || allows(.scheduleManage) || canManageWallpapers || allows(.rolesRead)
    }
    func canAssign(_ role: UserRole?, replacing previous: UserRole?) -> Bool {
        guard role != .admin, previous != .admin else { return false }
        return allows(role == .manager || previous == .manager ? .rolesManageManager : .rolesManageCreator)
    }
}

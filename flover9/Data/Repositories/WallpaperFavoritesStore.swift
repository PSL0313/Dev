//
//  WallpaperFavoritesStore.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Foundation

// 즐겨찾기 배경화면을 기기에 저장하고 변경 알림을 전달합니다.
@MainActor final class WallpaperFavoritesStore {
    // No actor-bound teardown; avoids an executor hop when released on iOS 26.2.
    nonisolated deinit {}
    static let changed = Notification.Name("WallpaperFavoritesChanged")
    private let defaults: UserDefaults
    private let key = "wallpaper.favorites.v1"
    
    init(defaults: UserDefaults = .standard) { self.defaults = defaults }
    
    var items: [WallpaperEntity] {
        guard let data = defaults.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([WallpaperEntity].self, from: data)) ?? []
    }
    
    /// 좋아요를 누른 배경화면인지 확인
    func contains(_ id: UUID) -> Bool { items.contains { $0.id == id } }
    
    /// 사용자가 버튼을 누르면 엔터티를 전달하고, 이미 가지고 있는 엔터티라면 삭제, 없으면 추가
    func toggle(_ wallpaper: WallpaperEntity) {
        var saved = items
        if contains(wallpaper.id) { saved.removeAll { $0.id == wallpaper.id } } else { saved.insert(wallpaper, at: 0) }
        defaults.set(try? JSONEncoder().encode(saved), forKey: key)
        NotificationCenter.default.post(name: Self.changed, object: nil)
    }
}

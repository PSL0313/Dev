//
//  SupabaseWallpaperRemoteDataSource.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Foundation
import Supabase

// Supabase 조회 뷰에서 시리즈와 배경화면을 검색하고 필터 선택지를 구성합니다.
final class SupabaseWallpaperRemoteDataSource: WallpaperRemoteDataSourceProtocol {
    nonisolated deinit {}
    private let client: SupabaseClient
    init(client: SupabaseClient) { self.client = client }
    func series(category: WallpaperCategory?, offset: Int, featuredOnly: Bool) async throws -> [WallpaperSeriesDTO] {
        let query = client.from("wallpaper_series_catalog").select("*").eq("is_published", value: true)
        if let category { query.eq("category", value: category.rawValue) }
        if featuredOnly { query.eq("is_featured", value: true) }
        return try await query.order("updated_at", ascending: false).order("id", ascending: false)
            .range(from: offset, to: offset + 29).execute().value
    }
    func wallpapers(in seriesID: UUID) async throws -> [WallpaperDTO] {
        var result: [WallpaperDTO] = []
        while true {
            let page: [WallpaperDTO] = try await client.from("wallpaper_catalog").select("*")
                .eq("series_id", value: seriesID).eq("is_published", value: true)
                .order("sort_order").order("id").range(from: result.count, to: result.count + 199).execute().value
            result += page
            if page.count < 200 { return result }
        }
    }
    func search(_ filter: WallpaperSearchFilter, offset: Int) async throws -> [WallpaperDTO] {
        let query = client.from("wallpaper_catalog").select("*").eq("is_published", value: true)
        if let category = filter.category { query.eq("category", value: category.rawValue) }
        if let creatorID = filter.creatorID { query.eq("creator_id", value: creatorID) }
        if let seriesID = filter.seriesID { query.eq("series_id", value: seriesID) }
        if let memberCode = filter.memberCode { query.contains("member_codes", value: [memberCode]) }
        let text = filter.query.trimmingCharacters(in: .whitespacesAndNewlines)
        if !text.isEmpty {
            let escaped = text.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "%", with: "\\%")
                .replacingOccurrences(of: "_", with: "\\_")
            query.ilike("search_text", pattern: "%\(escaped)%")
        }
        return try await query.order("created_at", ascending: false).order("id", ascending: false)
            .range(from: offset, to: offset + 29).execute().value
    }
    func options() async throws -> WallpaperFilterOptions {
        // 멤버 선택지에 필요한 코드와 표시 이름을 조회하는 응답입니다.
        struct Member: Decodable {
            let code: String // 멤버 고유 코드
            let display_name: String // 멤버 선택 화면에 표시할 이름
        }
        let members: [Member] = try await client.from("members").select("code,display_name").eq(
            "is_active", value: true
        ).eq("entity_type", value: "member").order("sort_order").execute().value
        var all: [WallpaperSeriesDTO] = []
        while true {
            let page: [WallpaperSeriesDTO] = try await client.from("wallpaper_series_catalog").select("*").eq(
                "is_published", value: true
            )
            .order("title").order("id").range(from: all.count, to: all.count + 199).execute().value
            all += page
            if page.count < 200 { break }
        }
        var creators: [String: String] = [:]
        all.forEach { creators[$0.creatorID.uuidString] = $0.creatorName }
        return WallpaperFilterOptions(
            members: members.map { .init(id: $0.code, title: $0.display_name) },
            creators: creators.map { .init(id: $0.key, title: $0.value) }.sorted { $0.title < $1.title },
            series: all.map { .init(id: $0.id.uuidString, title: $0.title) })
    }
}

//
//  SupabaseFeedRemoteDataSource.swift
//  flover9
//
//  Created by 박선린 on 8/7/26.
//
import Foundation
import Supabase

final class SupabaseFeedRemoteDataSource: FeedRemoteDataSourceProtocol {

    private let supabase: SupabaseClient

    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }

    // MARK: - 특정 멤버와 연결된 피드 목록 요약 조회
    func fetchFeeds(memberCode: MemberCode = .jiheon, limit: Int) async throws -> [FeedResponseDTO] {
        do {
            return try await supabase
                .from("feeds")
                .select(
                """
                id,
                user_id,
                title,
                source_name,
                description,
                capture_date,
                uploaded_at,
                source,
                permalink,
                thumbnail_url,
                display_type,
                content_count,
                feed_members!inner()
                """
                )
                .eq(
                    "feed_members.member",
                    value: memberCode.rawValue
                )
                .order("capture_date", ascending: false)
                .order("id", ascending: false)
                .limit(limit)
                .execute()
                .value
        } catch {
            throw SupabaseDataError.map(error) // SDK 오류를 Data 계층 오류로 통일
        }
    }

    // MARK: - 선택한 피드에 포함된 상세 미디어 조회
    func fetchFeedMedia(feedID: UUID) async throws -> [FeedImageDTO] {
        do {
            return try await supabase
                .from("feed_images")
                .select(
                """
                id,
                feed_id,
                image_url,
                sort_order,
                object_key,
                content_type,
                file_size,
                checksum_sha256,
                etag,
                uploaded_at
                """
                )
                .eq("feed_id", value: feedID)
                .order("sort_order", ascending: true)
                .execute()
                .value
        } catch {
            throw SupabaseDataError.map(error) // SDK 오류를 Data 계층 오류로 통일
        }
    }
}

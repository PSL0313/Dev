//
//  SupabaseFeedRemoteDataSource.swift
//  flover9
//
//  Created by 박선린 on 8/7/26.
//
import Foundation
import Supabase

final class SupabaseFeedRemoteDataSource: FeedRemoteDataSource {

    private let supabase: SupabaseClient

    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }

    func fetchFeeds(memberCode: MemberCode = .jiheon, limit: Int) async throws -> [FeedResponseDTO] {

        try await supabase
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

                feed_images (
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
                ),

                feed_members!inner (
                    id,
                    feed_id,
                    member,

                    members!inner (
                        code,
                        display_name,
                        sort_order,
                        is_active,
                        created_at
                    )
                )
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
    }
}

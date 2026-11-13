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
    func fetchFeeds(memberCode: MemberCode? = nil, limit: Int, offset: Int) async throws -> FeedPageDTO {
        do {
            guard limit > 0 else {
                return FeedPageDTO(feeds: [], hasMore: false)
            }

            let feedMemberJoin = memberCode == nil ? "" : ", feed_members!inner()"

            let columns = """
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
            content_count
            \(feedMemberJoin)
            """

            // 쿼리 생성: 조회할 테이블과 칼럼 추가
            var query = supabase
                .from("feeds")
                .select(columns)

            // memberCode가 있을 때만 특정 멤버로 필터 추가
            if let memberCode {
                query = query.eq(
                    "feed_members.member",
                    value: memberCode.rawValue
                )
            }

            // 범위 조회를 위한 오프셋 값
            let start = max(offset, 0)

            // 실행
            let result: [FeedResponseDTO] = try await query
                .order("capture_date", ascending: false)
                .order("id", ascending: false)
                .range(
                    from: start,
                    to: start + limit - 1
                )
                .execute()
                .value

            return FeedPageDTO(
                feeds: result,
                hasMore: result.count == limit
            )
        } catch {
            throw SupabaseDataError.map(error)
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

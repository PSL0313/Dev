import Foundation
import Supabase

// MARK: - 로그인한 사용자 세션으로만 관리 요청을 전송
@MainActor
final class SupabaseAdminRemoteDataSource: AdminRemoteDataSourceProtocol {
    private let client: SupabaseClient
    private let pageSize = 30
    private var pendingSaves: [UUID: () async throws -> Void] = [:]

    func hasPendingSave(id: UUID) -> Bool { pendingSaves[id] != nil }
    func endEditing(id: UUID) { pendingSaves[id] = nil }

    init(client: SupabaseClient) {
        self.client = client
    }

    func fetchMedia(category: AdminCategory, id: UUID) async throws -> [AdminMediaDTO] {
        do {
            let table = category == .feeds ? "feed_images" : "schedule_media"
            let column = category == .feeds ? "feed_id" : category == .events ? "event_id" : "schedule_id"
            return try await client.from(table).select("*").eq(column, value: id)
                .order("sort_order").order("id").execute().value
        } catch {
            throw SupabaseDataError.map(error)
        }
    }

    // MARK: - 현재 사용자 권한을 서버에서 다시 확인
    func fetchProfile() async throws -> ReadUserProfileDTO {
        do {
            let user = try await client.auth.user()
            return try await client.from("profiles")
                .select()
                .eq("id", value: user.id)
                .single()
                .execute()
                .value
        } catch {
            throw SupabaseDataError.map(error)
        }
    }

    // MARK: - 목록 조회
    func fetchFeeds(offset: Int, query: String) async throws -> [FeedResponseDTO] {
        do {
            let request = client.from("feeds").select("*")
            if !query.isEmpty {
                request.ilike("title", pattern: "%\(query)%")
            }
            return try await request
                .order("uploaded_at", ascending: false)
                .order("id", ascending: false)
                .range(from: offset, to: offset + pageSize - 1)
                .execute()
                .value
        } catch {
            throw SupabaseDataError.map(error)
        }
    }

    func fetchSchedules(offset: Int, query: String) async throws -> [ScheduleDTO] {
        do {
            let request = client.from("schedules")
                .select("*, schedule_events!inner(*), schedule_members(member_code)")
            if !query.isEmpty {
                request.ilike("schedule_events.title", pattern: "%\(query)%")
            }
            return try await request
                .order("start_at", ascending: false)
                .order("id", ascending: false)
                .range(from: offset, to: offset + pageSize - 1)
                .execute()
                .value
        } catch {
            throw SupabaseDataError.map(error)
        }
    }

    func fetchEvents(offset: Int, query: String) async throws -> [ScheduleEventDTO] {
        do {
            let request = client.from("schedule_events").select("*")
            if !query.isEmpty {
                request.ilike("title", pattern: "%\(query)%")
            }
            return try await request
                .order("created_at", ascending: false)
                .order("id", ascending: false)
                .range(from: offset, to: offset + pageSize - 1)
                .execute()
                .value
        } catch {
            throw SupabaseDataError.map(error)
        }
    }

    // MARK: - 저장 결과를 다시 받아 RLS로 0행 수정된 경우도 실패 처리
    func updateFeed(_ draft: AdminFeedDraft) async throws {
        try await saveMedia(targetID: draft.id, category: .feeds, isNew: false, fields: AdminFeedUpdateDTO(draft), edit: draft.mediaEdit, files: draft.media)
    }

    func saveSchedule(_ draft: AdminScheduleDraft, isNew: Bool) async throws {
        try await saveMedia(targetID: draft.id, category: .schedules, isNew: isNew, fields: AdminScheduleWriteDTO(draft: draft), edit: draft.mediaEdit, files: draft.media)
    }

    func saveEvent(_ draft: AdminEventDraft, isNew: Bool) async throws {
        try await saveMedia(targetID: draft.id, category: .events, isNew: isNew, fields: AdminEventWriteDTO(draft: draft), edit: draft.mediaEdit, files: draft.media)
    }

    // MARK: - 파일은 먼저 임시 업로드. 모두 성공한 경우에만 서버에 최종 저장 요청
    private func saveMedia<Draft: Encodable>(targetID: UUID, category: AdminCategory, isNew: Bool, fields: Draft, edit: AdminMediaEdit, files: [UploadMediaFile]) async throws {
        do {
            if let retry = pendingSaves[targetID] {
                try await retry()
                pendingSaves[targetID] = nil
                return
            }
            var sessionIDs: [UUID] = []
            let startOrder = (edit.existing.map(\.sortOrder).max() ?? -1) + 1
            for (index, file) in files.enumerated() {
                let request = AdminPresignRequestDTO(
                    action: category == .feeds ? "presignFeed" : category == .events ? "presignEvent" : "presignSchedule",
                    feedID: category == .feeds ? targetID : nil,
                    scheduleID: category == .schedules ? targetID : nil,
                    eventID: category == .events ? targetID : nil,
                    contentType: file.contentType.rawValue, mimeType: file.contentType.rawValue,
                    mediaType: file.contentType.isVideo ? "video" : "image",
                    fileSizeBytes: file.fileSizeBytes, sortOrder: startOrder + index
                )
                let signed: AdminSignedUploadDTO = try await client.functions.invoke("media-storage", options: FunctionInvokeOptions(body: request))
                var upload = URLRequest(url: signed.uploadURL)
                upload.httpMethod = "PUT"
                signed.requiredHeaders.forEach { upload.setValue($0.value, forHTTPHeaderField: $0.key) }
                upload.setValue(String(file.fileSizeBytes), forHTTPHeaderField: "Content-Length")
                let (_, response) = try await URLSession.shared.upload(for: upload, fromFile: file.fileURL)
                guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else { throw URLError(.badServerResponse) }
                sessionIDs.append(signed.uploadSessionID)
            }
            let request = AdminMediaSaveDTO(
                requestID: UUID(), targetID: targetID,
                targetType: category == .feeds ? "feed" : category == .events ? "event" : "schedule",
                isNew: isNew, draft: fields, expectedIDs: edit.existing.map(\.id),
                deletedIDs: Array(edit.removedIDs), sessionIDs: sessionIDs, displayRole: edit.displayRole
            )
            // 응답 유실 시 같은 요청 ID로 확인해 추가/삭제를 중복 실행하지 않습니다.
            let commit: () async throws -> Void = { [client] in
                let result: AdminMediaSavedDTO = try await client.functions.invoke("media-storage", options: FunctionInvokeOptions(body: request))
                guard result.saved else { throw URLError(.badServerResponse) }
            }
            pendingSaves[targetID] = commit
            try await commit()
            pendingSaves[targetID] = nil
        } catch {
            throw SupabaseDataError.map(error)
        }
    }

    // MARK: - DB만 직접 지우지 않고 R2 정리 큐까지 등록하는 기존 함수 사용
    func delete(_ item: AdminContent) async throws -> AdminDeleteResponseDTO {
        do {
            let action: String
            switch item {
            case .feed: action = "deleteFeed"
            case .schedule: action = "deleteSchedule"
            case .event: action = "deleteEvent"
            }
            return try await client.functions.invoke(
                "media-storage",
                options: FunctionInvokeOptions(
                    body: AdminDeleteRequestDTO(action: action, parentID: item.id)
                )
            )
        } catch {
            throw SupabaseDataError.map(error)
        }
    }
}

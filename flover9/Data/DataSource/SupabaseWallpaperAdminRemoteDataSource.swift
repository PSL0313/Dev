//
//  SupabaseWallpaperAdminRemoteDataSource.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Foundation
import Supabase

// 관리 API 호출과 새 이미지 업로드·검증·저장 재시도를 수행합니다.
@MainActor final class SupabaseWallpaperAdminRemoteDataSource: WallpaperAdminRemoteDataSourceProtocol {
    nonisolated deinit {}
    private let client: SupabaseClient
    private let uploadSession: URLSession
    // 같은 이미지의 업로드를 재시도할 때 재사용할 티켓과 진행 상태입니다.
    private struct UploadState {
        let ticketID: UUID // 이미지 업로드 작업을 식별하는 서버 티켓 ID
        let createdAt: Date // 업로드 상태 생성 시각; 티켓과 서명 URL의 재사용 가능 시간을 판단
        var signed: WallpaperSignedDTO? // 발급받은 업로드 URL과 필수 요청 헤더
        var uploaded = false // R2로 파일 전송을 완료했는지 여부
        var prepared = false // 서버에서 파일 검증을 마쳐 저장에 사용할 수 있는지 여부
    }
    private var uploads: [UUID: UploadState] = [:]
    private var pendingCommits: [UUID: Data] = [:]
    private var deletionRequests: [UUID: UUID] = [:]
    init(client: SupabaseClient, uploadSession: URLSession = .shared) {
        self.client = client
        self.uploadSession = uploadSession
    }
    func context() async throws -> WallpaperEditorContext {
        // 편집 가능한 제작자 목록과 현재 사용자 권한을 조회하기 위한 프로필 응답입니다.
        struct Profile: Decodable {
            let id: UUID // 제작자의 profiles.id
            let nickname: String? // 제작자 닉네임; 현재 DB에서는 nil 허용
            let role: String // 편집 권한 판단에 사용할 사용자 역할
        }
        // 멤버 선택지에 필요한 코드와 표시 이름을 조회하는 응답입니다.
        struct Member: Decodable {
            let code: String // 멤버 고유 코드
            let display_name: String // 멤버 선택 화면에 표시할 이름
        }
        let user = try await client.auth.user()
        let profile: Profile = try await client
            .from("profiles")
            .select("id,nickname,role")
            .eq("id", value: user.id)
            .single()
            .execute()
            .value
        guard ["manager", "admin", "blogger", "homema"].contains(profile.role) else {
            throw WallpaperError.server("배경화면 관리 권한이 없어요.")
        }
        let manager = ["manager", "admin"].contains(profile.role)
        let creators: [Profile]
        if manager {
            creators = try await client.from("profiles").select("id,nickname,role").in(
                "role", values: ["manager", "admin", "blogger", "homema"]
            ).order("nickname").execute().value
        } else {
            creators = [profile]
        }
        let members: [Member] = try await client.from("members").select("code,display_name").eq(
            "is_active", value: true
        ).eq("entity_type", value: "member").order("sort_order").execute().value
        return .init(
            userID: user.id, canFeature: manager,
            creators: creators.map { .init(id: $0.id.uuidString, title: $0.nickname ?? "Creator") },
            members: members.map { .init(id: $0.code, title: $0.display_name) })
    }
    func listSeries() async throws -> [WallpaperSeriesEntity] {
        let editor = try await context()
        var result: [WallpaperSeriesDTO] = []
        while true {
            let query = client.from("wallpaper_series_catalog").select("*")
            if !editor.canFeature { query.eq("creator_id", value: editor.userID) }
            let page: [WallpaperSeriesDTO] = try await query.order("created_at", ascending: false).order("id").range(
                from: result.count, to: result.count + 99
            ).execute().value
            result += page
            if page.count < 100 { return result.map { $0.entity() } }
        }
    }
    func listWallpapers(seriesID: UUID) async throws -> [WallpaperEntity] {
        var result: [WallpaperDTO] = []
        while true {
            let page: [WallpaperDTO] = try await client.from("wallpaper_catalog").select("*").eq(
                "series_id", value: seriesID
            )
            .order("sort_order").order("id").range(from: result.count, to: result.count + 199).execute().value
            result += page
            if page.count < 200 { return result.map { $0.entity() } }
        }
    }
    func saveSeries(_ draft: WallpaperSeriesDraft, isNew: Bool) async throws {
        if let pending = pendingCommits[draft.requestID] {
            try await sendCommit(pending, requestID: draft.requestID)
            return
        }
        var tickets: [UUID] = []
        if let file = draft.cover {
            tickets.append(try await prepare(file, seriesID: draft.id, wallpaperID: nil, slot: "cover"))
        }
        let payload = WallpaperSeriesFieldsDTO(
            title: draft.title, description: draft.description, creator_id: draft.creatorID,
            category: draft.category.rawValue, is_featured: draft.isFeatured, is_published: draft.isPublished)
        try await commit(
            WallpaperCommitDTO(
                action: "saveSeries", requestID: draft.requestID, id: draft.id, seriesID: draft.id,
                expectedRevision: isNew ? nil : draft.revision, payload: payload, ticketIDs: tickets))
    }
    func saveWallpaper(_ draft: WallpaperDraft, isNew: Bool) async throws {
        if let pending = pendingCommits[draft.requestID] {
            try await sendCommit(pending, requestID: draft.requestID)
            return
        }
        var tickets: [UUID] = []
        if let file = draft.mockup {
            tickets.append(try await prepare(file, seriesID: draft.seriesID, wallpaperID: draft.id, slot: "mockup"))
        }
        if let file = draft.original {
            tickets.append(try await prepare(file, seriesID: draft.seriesID, wallpaperID: draft.id, slot: "original"))
        }
        let payload = WallpaperFieldsDTO(
            sort_order: draft.sortOrder, member_codes: draft.memberCodes)
        try await commit(
            WallpaperCommitDTO(
                action: "saveWallpaper", requestID: draft.requestID, id: draft.id, seriesID: draft.seriesID,
                expectedRevision: isNew ? nil : draft.revision, payload: payload, ticketIDs: tickets))
    }
    func deleteSeries(_ series: WallpaperSeriesEntity) async throws {
        try await delete(action: "deleteSeries", id: series.id, seriesID: series.id, revision: series.revision)
    }
    func deleteWallpaper(_ wallpaper: WallpaperEntity) async throws {
        try await delete(
            action: "deleteWallpaper", id: wallpaper.id, seriesID: wallpaper.seriesID, revision: wallpaper.revision)
    }
    private func delete(action: String, id: UUID, seriesID: UUID, revision: Int) async throws {
        let requestID = deletionRequests[id] ?? UUID()
        deletionRequests[id] = requestID
        do {
            try await commit(
                WallpaperCommitDTO(
                    action: action, requestID: requestID, id: id, seriesID: seriesID, expectedRevision: revision,
                    payload: WallpaperEmptyDTO(), ticketIDs: []))
            deletionRequests[id] = nil
        } catch WallpaperError.server(let message) {
            deletionRequests[id] = nil
            throw WallpaperError.server(message)
        }
    }
    private func commit<T: Encodable>(_ body: WallpaperCommitDTO<T>) async throws {
        let data = try JSONEncoder().encode(body)
        pendingCommits[body.requestID] = data
        try await sendCommit(data, requestID: body.requestID)
    }
    private func sendCommit(_ data: Data, requestID: UUID) async throws {
        do {
            let result: WallpaperSavedDTO = try await client.functions.invoke(
                "wallpaper-media",
                options: FunctionInvokeOptions(headers: ["Content-Type": "application/json"], body: data))
            guard result.saved else { throw WallpaperError.uncertain }
            pendingCommits[requestID] = nil
        } catch let error as FunctionsError {
            if case .httpError(let code, let data) = error, code < 500 {
                pendingCommits[requestID] = nil
                let message =
                    (try? JSONSerialization.jsonObject(with: data) as? [String: String])?["error"]
                    ?? "저장하지 못했어요. 새로고침 후 다시 시도해 주세요."
                throw WallpaperError.server(message)
            }
            throw WallpaperError.uncertain
        } catch { throw WallpaperError.uncertain }
    }
    private func prepare(_ file: WallpaperImageFile, seriesID: UUID, wallpaperID: UUID?, slot: String) async throws
        -> UUID
    {
        if let old = uploads[file.id], Date().timeIntervalSince(old.createdAt) > 50 * 60 { uploads[file.id] = nil }
        var state = uploads[file.id] ?? UploadState(ticketID: UUID(), createdAt: Date())
        if state.prepared { return state.ticketID }
        defer { uploads[file.id] = state }
        if state.signed == nil || (!state.uploaded && Date().timeIntervalSince(state.createdAt) > 14 * 60) {
            let body = WallpaperUploadRequestDTO(
                action: "presign", ticketID: state.ticketID, seriesID: seriesID, wallpaperID: wallpaperID, slot: slot,
                contentType: file.contentType, fileSizeBytes: file.data.count, fileName: file.fileName)
            state.signed = try await client.functions.invoke(
                "wallpaper-media", options: FunctionInvokeOptions(body: body))
        }
        if !state.uploaded, let signed = state.signed {
            var request = URLRequest(url: signed.uploadURL)
            request.httpMethod = "PUT"
            signed.requiredHeaders.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
            let (_, response) = try await uploadSession.upload(for: request, from: file.data)
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                throw WallpaperError.server("이미지를 업로드하지 못했어요. 다시 시도해 주세요.")
            }
            state.uploaded = true
        }
        let prepared: WallpaperPreparedDTO = try await client.functions.invoke(
            "wallpaper-media",
            options: FunctionInvokeOptions(body: WallpaperUploadRequestDTO(action: "confirm", ticketID: state.ticketID))
        )
        guard prepared.prepared else { throw WallpaperError.server("이미지를 확인하지 못했어요.") }
        state.prepared = true
        return state.ticketID
    }
}

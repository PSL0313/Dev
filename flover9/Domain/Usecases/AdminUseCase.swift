import Foundation

// MARK: - 관리 작업 직전에 권한과 입력값을 다시 검증
@MainActor
final class AdminUseCase: AdminUseCaseProtocol {
    func endEditing(id: UUID) { repository.endEditing(id: id) }
    private let repository: AdminRepositoryProtocol
    private let createFeedUseCase: CreateFeedUseCaseProtocol

    init(repository: AdminRepositoryProtocol, createFeedUseCase: CreateFeedUseCaseProtocol) {
        self.repository = repository
        self.createFeedUseCase = createFeedUseCase
    }

    func authorize() async throws -> UserProfile {
        let profile = try await repository.fetchProfile()
        guard Self.canManage(profile.role) else {
            throw AdminError.permissionDenied
        }
        return profile
    }

    nonisolated static func canManage(_ role: UserRole) -> Bool {
        role == .admin || role == .manager
    }

    func fetchMedia(category: AdminCategory, id: UUID) async throws -> [AdminMediaItem] {
        _ = try await authorize()
        return try await repository.fetchMedia(category: category, id: id)
    }

    func fetchItems(category: AdminCategory, offset: Int, query: String) async throws -> [AdminContent] {
        _ = try await authorize()
        return try await repository.fetchItems(category: category, offset: offset, query: query)
    }

    func saveFeed(_ draft: AdminFeedDraft, isNew: Bool) async throws {
        _ = try await authorize()
        guard !draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AdminError.invalidInput("피드 제목을 입력해 주세요.")
        }

        if isNew {
            
            let permalink = try Self.optionalFeedURL(draft.permalink)
            guard ["instagram", "fromm", "blogger"].contains(draft.source) else {
                throw AdminError.invalidInput("지원하지 않는 콘텐츠 출처예요.")
            }
            guard !draft.members.isEmpty else {
                throw AdminError.invalidInput("피드에 등장하는 멤버를 선택해 주세요.")
            }
            guard !draft.media.isEmpty, draft.media.count <= 20 else {
                throw AdminError.invalidInput("사진 또는 MP4 파일을 1~20개 선택해 주세요.")
            }

            // 기존 배치 업로드가 전체 파일 전송 후에만 피드를 확정한다.
            _ = try await createFeedUseCase.execute(
                draft: FeedUploadDraft(
                    id: draft.id,
                    title: draft.title,
                    sourceName: draft.sourceName,
                    description: draft.description,
                    captureDate: draft.captureDate,
                    source: draft.source,
                    permalink: permalink,
                    memberCodes: draft.members,
                    media: draft.media
                )
            )
            await repository.invalidateCaches()
        } else {
            let remaining = draft.mediaEdit.existing.count - draft.mediaEdit.removedIDs.count + draft.media.count
            guard remaining > 0, remaining <= 20 else {
                throw AdminError.invalidInput("피드에는 미디어가 1~20개 있어야 해요. 피드 전체 삭제는 별도 삭제 메뉴를 사용해 주세요.")
            }
            try await repository.updateFeed(draft)
        }
    }

    // 원본 링크는 선택 입력이며, 입력한 경우에만 웹 주소인지 확인한다.
    nonisolated static func optionalFeedURL(_ value: String) throws -> URL? {
        let value = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return nil }
        guard let url = webURL(value) else {
            throw AdminError.invalidInput("원본 링크를 https:// 형식으로 입력해 주세요.")
        }
        return url
    }

    func saveSchedule(_ draft: AdminScheduleDraft, isNew: Bool) async throws {
        _ = try await authorize()
        try Self.validateSchedule(draft)
        try await repository.saveSchedule(draft, isNew: isNew)
    }

    nonisolated static func validateSchedule(_ draft: AdminScheduleDraft) throws {
        if let endAt = draft.endAt, endAt < draft.startAt {
            throw AdminError.invalidInput("종료 시간은 시작 시간보다 빠를 수 없어요.")
        }
        guard TimeZone(identifier: draft.timeZone) != nil else {
            throw AdminError.invalidInput("올바른 시간대를 입력해 주세요. 예: Asia/Seoul")
        }
    }

    func saveEvent(_ draft: AdminEventDraft, isNew: Bool) async throws {
        _ = try await authorize()
        guard !draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AdminError.invalidInput("행사 이름을 입력해 주세요.")
        }
        for value in [draft.reservationURL, draft.thumbnailURL] where !value.isEmpty {
            guard Self.webURL(value) != nil else {
                throw AdminError.invalidInput("주소는 http:// 또는 https://로 시작해야 해요.")
            }
        }
        try await repository.saveEvent(draft, isNew: isNew)
    }

    func delete(_ item: AdminContent) async throws -> Bool {
        _ = try await authorize()
        return try await repository.delete(item)
    }

    nonisolated static func webURL(_ value: String) -> URL? {
        guard
            let url = URL(string: value),
            let scheme = url.scheme?.lowercased(),
            ["https", "http"].contains(scheme),
            url.host?.isEmpty == false
        else {
            return nil
        }
        return url
    }
}

import Foundation

@MainActor
final class AdminEditorViewModel {
    // 종료 시 별도 UI 정리가 없어 executor로 옮기는 비동기 소멸이 필요하지 않습니다.
    nonisolated deinit {}
    enum State {
        case checking
        case editing
        case saving
    }

    enum Route {
        case saved
        case confirmDelete(AdminContent)
        case deleted(Bool)
        case failed(String)
        case accessDenied(String)
        case editEvent(ScheduleEventEntity)
    }

    let mode: AdminEditorMode
    var onState: ((State) -> Void)?
    var onRoute: ((Route) -> Void)?
    var onMediaChange: (() -> Void)?
    private var hasLoadedMedia = false
    private var localMediaIDs: [URL: UUID] = [:]
    var feed = AdminFeedDraft()
    var schedule: AdminScheduleDraft?
    var event = AdminEventDraft()
    private(set) var isSaving = false
    private(set) var isDeleting = false
    private(set) var isSaveUnconfirmed = false
    private(set) var isAuthorized = false

    private let useCase: AdminUseCaseProtocol
    private let logger: ErrorLogging
    private var task: Task<Void, Never>?

    init(mode: AdminEditorMode, useCase: AdminUseCaseProtocol, logger: ErrorLogging) {
        self.mode = mode
        self.useCase = useCase
        self.logger = logger
        configureDraft()
    }

    // MARK: - 수정 화면은 원본 Entity에서 입력값을 채운다.
    private func configureDraft() {
        switch mode {
        case .editFeed(let value):
            feed.id = value.id
            feed.title = value.title ?? ""
            feed.sourceName = value.sourceName ?? ""
            feed.description = value.description ?? ""
            feed.source = value.source
            feed.permalink = value.permalink ?? ""
            feed.captureDate = value.captureDate
        case .newSchedule(let value):
            schedule = AdminScheduleDraft(eventID: value.id)
        case .editSchedule(let value):
            schedule = AdminScheduleDraft(
                id: value.id,
                eventID: value.event.id,
                startAt: value.startAt,
                endAt: value.endAt,
                venueName: value.venueName == value.event.venueName ? "" : value.venueName ?? "",
                status: value.status,
                isAllDay: value.isAllDay,
                timeZone: value.timeZone
            )
        case .editEvent(let value):
            event.id = value.id
            event.title = value.title
            event.type = value.type
            event.venueName = value.venueName ?? ""
            event.description = value.description ?? ""
            event.reservationURL = value.reservationURL?.absoluteString ?? ""
            event.thumbnailURL = value.thumbnailURL?.absoluteString ?? ""
        case .newFeed, .newEvent:
            break
        }
    }

    func checkAccess() {
        guard !isSaving else { return }
        task?.cancel()
        isAuthorized = false
        onState?(.checking)
        task = Task { [weak self] in
            guard let self else { return }
            do {
                _ = try await useCase.authorize()
                if !mode.isNew && !hasLoadedMedia {
                    mediaEdit.existing = try await useCase.fetchMedia(category: mediaCategory, id: contentID)
                    hasLoadedMedia = true
                    onMediaChange?()
                }
                guard !Task.isCancelled else { return }
                isAuthorized = true
                onState?(.editing)
            } catch {
                guard !Task.isCancelled else { return }
                let failure = error as? AdminError ?? .serverUnavailable
                onRoute?(.accessDenied(failure.userMessage))
            }
        }
    }

    // MARK: - 화면은 미디어 편집 상태만 바꾸고 서버 요청은 저장할 때 수행
    var mediaCategory: AdminCategory {
        switch mode {
        case .newFeed, .editFeed: return .feeds
        case .newSchedule, .editSchedule: return .schedules
        case .newEvent, .editEvent: return .events
        }
    }

    func endEditing() { useCase.endEditing(id: contentID) }

    // 전체 삭제는 사진의 삭제 예약과 별개이며 확인창을 거친다.
    func requestDeletion() {
        guard isAuthorized, !isSaving, !isSaveUnconfirmed, let item = mode.existingContent else { return }
        onRoute?(.confirmDelete(item))
    }

    func delete() {
        guard isAuthorized, !isSaving, !isSaveUnconfirmed, let item = mode.existingContent else { return }
        isSaving = true
        isDeleting = true
        onState?(.saving)
        task = Task { [weak self] in
            guard let self else { return }
            do {
                let queued = try await useCase.delete(item)
                endEditing()
                isSaving = false
                isDeleting = false
                onRoute?(.deleted(queued))
            } catch {
                isSaving = false
                isDeleting = false
                let failure = error as? AdminError ?? .serverUnavailable
                onState?(.editing)
                onRoute?(.failed(failure.userMessage))
                await logger.record(failure)
            }
        }
    }

    var contentID: UUID {
        switch mediaCategory {
        case .feeds: return feed.id
        case .schedules: return schedule!.id
        case .events: return event.id
        }
    }

    var mediaEdit: AdminMediaEdit {
        get {
            switch mediaCategory {
            case .feeds: return feed.mediaEdit
            case .schedules: return schedule!.mediaEdit
            case .events: return event.mediaEdit
            }
        }
        set {
            switch mediaCategory {
            case .feeds: feed.mediaEdit = newValue
            case .schedules: schedule?.mediaEdit = newValue
            case .events: event.mediaEdit = newValue
            }
        }
    }

    var selectedFiles: [UploadMediaFile] {
        get {
            switch mediaCategory {
            case .feeds: return feed.media
            case .schedules: return schedule!.media
            case .events: return event.media
            }
        }
        set {
            switch mediaCategory {
            case .feeds: feed.media = newValue
            case .schedules: schedule?.media = newValue
            case .events: event.media = newValue
            }
        }
    }

    var previewItems: [FeedImageEntity] {
        let remote = mediaEdit.existing.map {
            FeedImageEntity(id: $0.id, feedId: contentID, imageURL: $0.url, sortOrder: $0.sortOrder, contentType: $0.contentType)
        }
        let local = selectedFiles.compactMap { file -> FeedImageEntity? in
            guard let id = localMediaIDs[file.fileURL] else { return nil }
            return FeedImageEntity(id: id, feedId: contentID, imageURL: file.fileURL, sortOrder: file.sortOrder, contentType: file.contentType)
        }
        return remote + local
    }

    func appendFiles(_ files: [UploadMediaFile]) throws {
        let remaining = mediaEdit.existing.count - mediaEdit.removedIDs.count + selectedFiles.count
        guard remaining + files.count <= 20 else {
            throw AdminError.invalidInput("한 번에 관리할 미디어는 최대 20개예요.")
        }
        for file in files { localMediaIDs[file.fileURL] = UUID() }
        selectedFiles = (selectedFiles + files).enumerated().map { index, file in
            UploadMediaFile(fileURL: file.fileURL, contentType: file.contentType, fileSizeBytes: file.fileSizeBytes, sortOrder: index)
        }
        onMediaChange?()
    }

    func toggleRemoval(_ id: UUID) {
        guard !isSaving else { return }
        if let url = localMediaIDs.first(where: { $0.value == id })?.key {
            selectedFiles.removeAll { $0.fileURL == url }
            selectedFiles = selectedFiles.enumerated().map { index, file in
                UploadMediaFile(fileURL: file.fileURL, contentType: file.contentType, fileSizeBytes: file.fileSizeBytes, sortOrder: index)
            }
            localMediaIDs.removeValue(forKey: url)
        } else if mediaEdit.removedIDs.contains(id) {
            mediaEdit.removedIDs.remove(id)
        } else {
            mediaEdit.removedIDs.insert(id)
        }
        onMediaChange?()
    }

    // MARK: - 저장 중 화면을 닫지 않아 업로드와 파일 수명을 보장
    func save() {
        guard isAuthorized, !isSaving else { return }
        isSaving = true
        onState?(.saving)
        task = Task { [weak self] in
            guard let self else { return }
            do {
                switch mode {
                case .newFeed, .editFeed:
                    try await useCase.saveFeed(feed, isNew: mode.isNew)
                case .newSchedule, .editSchedule:
                    guard let schedule else { throw AdminError.serverUnavailable }
                    try await useCase.saveSchedule(schedule, isNew: mode.isNew)
                case .newEvent, .editEvent:
                    try await useCase.saveEvent(event, isNew: mode.isNew)
                }
                isSaving = false
                onRoute?(.saved)
            } catch {
                isSaving = false
                onState?(.editing)
                if let mediaError = error as? MediaUploadError {
                    onRoute?(.failed(mediaError.userMessage))
                    await logger.record(mediaError)
                } else {
                    let failure = error as? AdminError ?? .serverUnavailable
                    isSaveUnconfirmed = failure == .saveUnconfirmed
                    onState?(.editing)
                    if failure == .permissionDenied {
                        isAuthorized = false
                        onRoute?(.accessDenied(failure.userMessage))
                    } else {
                        onRoute?(.failed(failure.userMessage))
                    }
                    await logger.record(failure)
                }
            }
        }
    }
}

//
//  WallpaperSeriesEditorViewModel.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Foundation

// 시리즈 제목·제작자·분류·대표 이미지·공개 상태 편집의 데이터와 로딩·오류 상태를 관리합니다.
@MainActor final class WallpaperSeriesEditorViewModel {
    nonisolated deinit {}
    private let manage: ManageWallpapersUseCase // 편집 검증과 저장·삭제를 제공하는 UseCase
    private(set) var existing: WallpaperSeriesEntity? // 수정할 기존 항목; nil이면 새 항목 생성
    var draft: WallpaperSeriesDraft // 사용자가 편집 중인 값과 새 이미지
    private(set) var context: WallpaperEditorContext? // 편집 권한과 선택 가능한 제작자·멤버 정보
    private(set) var isSaving = false // 저장 요청을 처리 중인지 여부
    private(set) var isLoading = false // 데이터를 불러오는 중인지 여부
    private(set) var isUncertain = false // 저장 응답을 확인하지 못해 동일 요청 재확인이 필요한지 여부
    var hasChanges = false // 저장하지 않은 편집 내용이 있는지 여부
    private var frozenDraft: WallpaperSeriesDraft? // 저장 결과가 불확실할 때 같은 내용으로 재시도하기 위해 고정한 편집 값
    var onChange: (() -> Void)? // 상태 변경 후 화면 갱신을 요청하는 콜백
    var onError: ((String) -> Void)? // 오류 메시지를 화면에 전달하는 콜백
    var onSaved: (() -> Void)? // 저장 완료 후 화면 이동 등을 요청하는 콜백
    init(series: WallpaperSeriesEntity?, manage: ManageWallpapersUseCase) {
        self.manage = manage
        existing = series
        draft = .init(
            id: series?.id ?? UUID(), title: series?.title ?? "", creatorID: series?.creatorID ?? UUID(),
            category: series?.category ?? .general, isFeatured: series?.isFeatured ?? false,
            isPublished: series?.isPublished ?? false, cover: nil, description: series?.description ?? "",
            revision: series?.revision)
    }
    func load() {
        guard !isLoading else { return }
        isLoading = true
        onChange?()
        Task { [weak self] in
            guard let self else { return }
            do {
                context = try await manage.context()
                if existing == nil, !hasChanges { draft.creatorID = context!.userID }
                if let existing, !hasChanges,
                    let refreshed = try await manage.series().first(where: { $0.id == existing.id })
                {
                    self.existing = refreshed
                    draft = .init(
                        id: refreshed.id, title: refreshed.title, creatorID: refreshed.creatorID,
                        category: refreshed.category, isFeatured: refreshed.isFeatured,
                        isPublished: refreshed.isPublished, cover: nil, description: refreshed.description,
                        revision: refreshed.revision)
                }
            } catch { onError?(error.localizedDescription) }
            isLoading = false
            onChange?()
        }
    }
    func save() {
        guard !isSaving && !isLoading && context != nil else { return }
        if frozenDraft == nil {
            draft.requestID = UUID()
            frozenDraft = draft
        }
        guard let attempt = frozenDraft else { return }
        isSaving = true
        onChange?()
        Task { [weak self] in
            guard let self else { return }
            do {
                try await manage.save(attempt, isNew: existing == nil)
                isSaving = false
                isUncertain = false
                hasChanges = false
                onChange?()
                onSaved?()
            } catch {
                isSaving = false
                if case WallpaperError.uncertain = error {
                    isUncertain = true
                } else {
                    isUncertain = false
                    frozenDraft = nil
                }
                onChange?()
                onError?(error.localizedDescription)
            }
        }
    }
}

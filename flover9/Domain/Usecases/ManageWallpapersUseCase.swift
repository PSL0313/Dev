//
//  ManageWallpapersUseCase.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Foundation

// 편집 값과 이미지 조건을 검증한 뒤 저장소에 저장·삭제를 요청합니다.
final class ManageWallpapersUseCase {
    // No actor-bound teardown; avoids an executor hop when released on iOS 26.2.
    nonisolated deinit {}
    private let repository: WallpaperAdminRepositoryProtocol
    init(repository: WallpaperAdminRepositoryProtocol) { self.repository = repository }
    func context() async throws -> WallpaperEditorContext { try await repository.context() }
    func series() async throws -> [WallpaperSeriesEntity] { try await repository.listSeries() }
    func wallpapers(seriesID: UUID) async throws -> [WallpaperEntity] {
        try await repository.listWallpapers(seriesID: seriesID)
    }
    func save(_ draft: WallpaperSeriesDraft, isNew: Bool) async throws {
        try validateTitle(draft.title)
        guard draft.description.count <= 2000 else { throw WallpaperError.validation("설명은 2,000자까지 입력해 주세요.") }
        if let cover = draft.cover { try validateFile(cover, cover: true) }
        try await repository.saveSeries(draft, isNew: isNew)
    }
    func save(_ draft: WallpaperDraft, isNew: Bool) async throws {
        guard draft.sortOrder >= 0 && draft.sortOrder <= Int(Int32.max) else {
            throw WallpaperError.validation("정렬 순서는 0 이상의 숫자로 입력해 주세요.")
        }
        guard Set(draft.memberCodes).count == draft.memberCodes.count else {
            throw WallpaperError.validation("멤버가 중복 선택되었어요.")
        }
        if isNew && (draft.mockup == nil || draft.original == nil) {
            throw WallpaperError.validation("목업과 원본을 모두 선택해 주세요.")
        }
        if let file = draft.mockup { try validateFile(file, cover: false) }
        if let file = draft.original { try validateFile(file, cover: false) }
        try await repository.saveWallpaper(draft, isNew: isNew)
    }
    private func validateTitle(_ title: String) throws {
        let text = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty && text.count <= 120 else { throw WallpaperError.validation("제목은 1~120자로 입력해 주세요.") }
    }
    private func validateFile(_ file: WallpaperImageFile, cover: Bool) throws {
        guard ["image/jpeg", "image/png", "image/webp"].contains(file.contentType) else {
            throw WallpaperError.validation("JPG, PNG, WebP 이미지를 선택해 주세요.")
        }
        guard !file.data.isEmpty && file.data.count <= (cover ? 10 : 50) * 1024 * 1024 else {
            throw WallpaperError.validation(cover ? "대표 썸네일은 10MB까지 업로드할 수 있어요." : "목업과 원본은 각각 50MB까지 업로드할 수 있어요.")
        }
    }
    func deleteSeries(_ series: WallpaperSeriesEntity) async throws { try await repository.deleteSeries(series) }
    func deleteWallpaper(_ wallpaper: WallpaperEntity) async throws { try await repository.deleteWallpaper(wallpaper) }
}

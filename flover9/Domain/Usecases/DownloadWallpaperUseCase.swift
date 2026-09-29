//
//  DownloadWallpaperUseCase.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Foundation

// 선택한 배경화면의 원본 URL을 검증하고 다운로드를 요청합니다.
final class DownloadWallpaperUseCase {
    // No actor-bound teardown; avoids an executor hop when released on iOS 26.2.
    nonisolated deinit {}
    private let repository: WallpaperDownloadRepositoryProtocol
    init(repository: WallpaperDownloadRepositoryProtocol) { self.repository = repository }
    func execute(_ wallpaper: WallpaperEntity) async throws -> URL {
        guard let url = wallpaper.originalURL, url.scheme == "https" else {
            throw WallpaperError.validation("원본 이미지를 찾지 못했어요.")
        }
        return try await repository.download(url)
    }
}

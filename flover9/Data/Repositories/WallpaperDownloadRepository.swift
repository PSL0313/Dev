//
//  WallpaperDownloadRepository.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Foundation
import ImageIO

// 원본 이미지 URL의 데이터를 공유 가능한 임시 파일로 다운로드합니다.
final class WallpaperDownloadRepository: WallpaperDownloadRepositoryProtocol {
    nonisolated deinit {}
    private let session: URLSession
    init(session: URLSession = .shared) { self.session = session }
    func download(_ url: URL) async throws -> URL {
        let (temporary, response) = try await session.download(from: url)
        defer { try? FileManager.default.removeItem(at: temporary) }
        guard let response = response as? HTTPURLResponse, (200..<300).contains(response.statusCode),
            let mime = response.mimeType,
            let ext = ["image/jpeg": "jpg", "image/png": "png", "image/webp": "webp"][mime]
        else { throw WallpaperError.server("원본 이미지를 다운로드하지 못했어요.") }
        let size = try temporary.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
        guard size > 0 && size <= 50 * 1024 * 1024, let image = CGImageSourceCreateWithURL(temporary as CFURL, nil),
            CGImageSourceGetCount(image) > 0
        else { throw WallpaperError.server("다운로드한 이미지가 올바르지 않아요.") }
        try Task.checkCancellation()
        let destination = FileManager.default.temporaryDirectory.appendingPathComponent(
            "Wallpaper-\(UUID().uuidString).\(ext)")
        try FileManager.default.moveItem(at: temporary, to: destination)
        return destination
    }
}

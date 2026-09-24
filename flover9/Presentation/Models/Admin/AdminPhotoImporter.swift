import PhotosUI
import UniformTypeIdentifiers

// MARK: - 시스템 사진 선택기를 사용하므로 전체 사진 보관함 권한이 필요하지 않음
@MainActor
enum AdminPhotoImporter {
    static func copy(_ results: [PHPickerResult]) async throws -> [(directory: URL, files: [UploadMediaFile])] {
        var imported: [(directory: URL, files: [UploadMediaFile])] = []
        do {
            for result in results {
                let value = try await copyFile(result.itemProvider)
                imported.append(value)
            }
            return imported
        } catch {
            // 한 장이라도 준비하지 못하면 이번 선택에서 복사한 파일만 정리합니다.
            imported.forEach { try? FileManager.default.removeItem(at: $0.directory) }
            throw error
        }
    }

    private static func copyFile(_ provider: NSItemProvider) async throws -> (directory: URL, files: [UploadMediaFile]) {
        try await withCheckedThrowingContinuation { continuation in
            provider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { url, error in
                guard let url else {
                    continuation.resume(throwing: error ?? AdminError.invalidInput("사진을 가져오지 못했어요. iCloud 다운로드 상태를 확인해 주세요."))
                    return
                }
                do {
                    // 제공된 임시 URL은 콜백이 끝나기 전에 복사해야 합니다.
                    continuation.resume(returning: try AdminMediaImporter.copy([url]))
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

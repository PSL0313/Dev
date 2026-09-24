import Foundation

// MARK: - 대용량 파일을 메모리에 올리지 않고 복사
nonisolated enum AdminMediaImporter {
    static func copy(_ urls: [URL]) throws -> (directory: URL, files: [UploadMediaFile]) {
        let manager = FileManager.default
        let directory = manager.temporaryDirectory.appendingPathComponent("admin-media-\(UUID().uuidString)")
        try manager.createDirectory(at: directory, withIntermediateDirectories: true)

        do {
            var files: [UploadMediaFile] = []
            for (index, url) in urls.enumerated() {
                let access = url.startAccessingSecurityScopedResource()
                defer { if access { url.stopAccessingSecurityScopedResource() } }
                let type: FeedMediaType
                switch url.pathExtension.lowercased() {
                case "jpg", "jpeg": type = .jpeg
                case "png": type = .png
                case "heic": type = .heic
                case "webp": type = .webp
                case "mp4": type = .mp4
                default: throw AdminError.invalidInput("JPEG, PNG, HEIC, WebP 또는 MP4 파일만 선택할 수 있어요.")
                }
                let size = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
                guard size > 0, size <= 1_073_741_824 else {
                    throw AdminError.invalidInput("파일은 비어 있지 않아야 하며, 하나당 1GB 이하여야 해요.")
                }
                let destination = directory.appendingPathComponent("\(index + 1)-\(url.lastPathComponent)")
                try manager.copyItem(at: url, to: destination)
                files.append(UploadMediaFile(
                    fileURL: destination,
                    contentType: type,
                    fileSizeBytes: Int64(size),
                    sortOrder: index
                ))
            }
            return (directory, files)
        } catch {
            try? manager.removeItem(at: directory)
            throw error
        }
    }
}

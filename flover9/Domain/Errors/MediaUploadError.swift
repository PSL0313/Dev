// MARK: - 미디어 업로드와 정리 과정의 Domain 오류
nonisolated enum MediaUploadError: Error, Sendable, Equatable {
    case unauthenticated
    case permissionDenied
    case emptyMedia
    case invalidFile
    case unsupportedMediaType
    case fileTooLarge
    case duplicatedSortOrder
    case uploadFailed
    case finalizationFailed
    case cleanupPending
    case networkUnavailable
    case serverUnavailable
    case unknown
}

extension MediaUploadError {
    nonisolated var userMessage: String {
        switch self {
        case .unauthenticated:
            return "로그인 세션을 확인할 수 없습니다."
        case .permissionDenied:
            return "미디어를 업로드하거나 삭제할 권한이 없습니다."
        case .emptyMedia:
            return "업로드할 사진 또는 영상을 선택해 주세요."
        case .invalidFile:
            return "선택한 파일을 읽을 수 없습니다."
        case .unsupportedMediaType:
            return "지원하지 않는 파일 형식입니다."
        case .fileTooLarge:
            return "파일 크기는 1GB 이하여야 합니다."
        case .duplicatedSortOrder:
            return "미디어 표시 순서가 중복되었습니다."
        case .uploadFailed:
            return "미디어 업로드에 실패했습니다. 다시 시도해 주세요."
        case .finalizationFailed:
            return "게시물을 저장하지 못했습니다. 업로드된 파일을 정리했습니다."
        case .cleanupPending:
            return "업로드 취소 후 일부 파일을 정리 중입니다."
        case .networkUnavailable:
            return "네트워크 연결을 확인해 주세요."
        case .serverUnavailable:
            return "미디어 서버를 사용할 수 없습니다. 잠시 후 다시 시도해 주세요."
        case .unknown:
            return "미디어 처리 중 알 수 없는 오류가 발생했습니다."
        }
    }
}

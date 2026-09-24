import Foundation

// MARK: - 관리자 미디어 목록은 소유 대상과 관계없이 같은 형태로 표시
nonisolated struct AdminMediaDTO: Decodable {
    let id: UUID
    let image_url: String?
    let media_url: String?
    let content_type: String?
    let mime_type: String?
    let sort_order: Int

    func toEntity() throws -> AdminMediaItem {
        guard let url = URL(string: image_url ?? media_url ?? ""),
              let type = FeedMediaType(rawValue: content_type ?? mime_type ?? "") else {
            throw AdminError.serverUnavailable
        }
        return AdminMediaItem(id: id, url: url, contentType: type, sortOrder: sort_order)
    }
}

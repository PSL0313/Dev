import Foundation

// MARK: - 앱에서 사용하는 로컬 음악 카탈로그

/// JSON에서 읽은 음악 정보를 앱의 Domain 계층에서 사용하는 모델입니다.
nonisolated struct MusicCatalogEntity: Sendable, Equatable {
    /// 로드된 카탈로그 구조의 버전입니다.
    let schemaVersion: Int

    /// JSON에 정의된 순서를 유지하는 앨범 목록입니다.
    let albums: [MusicAlbumEntity]
}

// MARK: - MusicKit 데이터와 외부 플랫폼 식별자를 연결하는 앨범

/// 앱 내부 앨범 ID와 각 음악 플랫폼의 앨범 ID를 연결하는 Domain 모델입니다.
nonisolated struct MusicAlbumEntity: Identifiable, Sendable, Equatable, Hashable {
    /// 앱 내부에서 앨범을 식별하는 고유 ID입니다.
    let id: String

    /// 앨범에 참여한 아티스트의 고정 ID 목록입니다.
    let artistIDs: [String]

    /// 플랫폼별 앨범 ID입니다.
    let platformIDs: MusicPlatformIDsEntity

    /// 앨범에 포함된 곡 목록입니다.
    let tracks: [MusicTrackEntity]
}

// MARK: - MusicKit 데이터와 외부 플랫폼 식별자를 연결하는 곡

/// 앱 내부 곡 ID와 각 음악 플랫폼의 곡 ID를 연결하는 Domain 모델입니다.
nonisolated struct MusicTrackEntity: Identifiable, Sendable, Equatable, Hashable {
    /// 앱 내부에서 곡을 식별하는 고유 ID입니다.
    let id: String

    /// 앨범의 아티스트와 다를 때 사용하는 곡별 아티스트 ID 목록입니다.
    let artistIDs: [String]?

    /// 해당 곡이 앨범의 타이틀곡인지 나타냅니다.
    let isTitleTrack: Bool

    /// 플랫폼별 곡 ID입니다.
    let platformIDs: MusicPlatformIDsEntity

    /// 곡에서 실제로 사용할 아티스트 ID 목록을 반환합니다.
    ///
    /// - Parameter albumArtistIDs: 곡이 속한 앨범의 아티스트 ID 목록입니다.
    /// - Returns: 곡별 아티스트가 있으면 그 값을, 없으면 앨범 아티스트를 반환합니다.
    nonisolated func resolvedArtistIDs(albumArtistIDs: [String]) -> [String] {
        artistIDs ?? albumArtistIDs
    }
}

// MARK: - 플랫폼별 외부 카탈로그 식별자

/// 앨범이나 곡의 외부 음악 플랫폼별 ID를 보관하는 Domain 모델입니다.
nonisolated struct MusicPlatformIDsEntity: Sendable, Equatable, Hashable {
    /// Apple Music의 앨범 또는 곡 ID입니다.
    let appleMusic: String?

    /// YouTube Music의 앨범 재생목록 ID 또는 곡 영상 ID입니다.
    let youtubeMusic: String?

    /// Spotify의 앨범 또는 트랙 ID입니다.
    let spotify: String?

    /// Melon의 앨범 또는 곡 ID입니다.
    let melon: String?

    /// 지정한 플랫폼에 해당하는 앨범 또는 곡 ID를 반환합니다.
    nonisolated subscript(platform: MusicPlatform) -> String? {
        switch platform {
        case .appleMusic: appleMusic
        case .youtubeMusic: youtubeMusic
        case .spotify: spotify
        case .melon: melon
        }
    }
}

// MARK: - Flover9에서 지원하는 음악 플랫폼

/// Flover9이 음악 바로가기를 제공하는 플랫폼입니다.
nonisolated enum MusicPlatform: String, CaseIterable, Sendable, Equatable, Hashable {
    /// Apple Music
    case appleMusic
    /// YouTube Music
    case youtubeMusic
    /// Spotify
    case spotify
    /// Melon
    case melon
}

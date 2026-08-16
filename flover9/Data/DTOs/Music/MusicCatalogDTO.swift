import Foundation

// MARK: - 로컬 음악 카탈로그 JSON DTO

/// 앱 번들에 포함된 음악 카탈로그 JSON의 최상위 구조입니다.
///
/// 정규 앨범과 기타 참여 앨범은 서로 다른 JSON 파일에서 디코딩하지만,
/// 두 파일 모두 같은 카탈로그 구조를 사용합니다.
nonisolated struct MusicCatalogDTO: Decodable, Sendable {
    /// JSON 구조의 버전입니다. 향후 필드 구조가 변경될 때 호환성을 구분합니다.
    let schemaVersion: Int

    /// JSON에 기록된 순서를 유지하는 앨범 목록입니다.
    let albums: [MusicAlbumDTO]
}

// MARK: - 앨범과 플랫폼 식별자의 연결 정보

/// 하나의 앨범과 각 음악 플랫폼의 앨범 ID를 연결하는 전송 객체입니다.
nonisolated struct MusicAlbumDTO: Decodable, Sendable {
    /// 앱 내부에서 앨범을 구분하기 위한 고유 ID입니다.
    let id: String

    /// 앨범에 참여한 아티스트의 고정 ID 목록입니다.
    /// 곡에 별도의 `artistIds`가 없다면 이 값을 곡의 아티스트로 사용합니다.
    let artistIDs: [String]

    /// Apple Music, YouTube Music, Spotify, Melon의 앨범 ID입니다.
    let platformIDs: MusicPlatformIDsDTO

    /// 앨범에 포함된 곡 목록입니다.
    let tracks: [MusicTrackDTO]

    /// Swift의 `ID` 표기와 JSON의 `Ids` 표기 차이를 연결합니다.
    enum CodingKeys: String, CodingKey {
        case id, tracks
        case artistIDs = "artistIds"
        case platformIDs = "platformIds"
    }
}

// MARK: - 곡과 플랫폼 식별자의 연결 정보

/// 하나의 곡과 각 음악 플랫폼의 곡 ID를 연결하는 전송 객체입니다.
nonisolated struct MusicTrackDTO: Decodable, Sendable {
    /// 앱 내부에서 곡을 구분하기 위한 고유 ID입니다.
    let id: String

    /// 앨범의 아티스트와 다를 때만 지정하는 곡별 아티스트 ID 목록입니다.
    /// `nil`이면 소속 앨범의 `artistIDs`를 상속합니다.
    let artistIDs: [String]?

    /// 해당 곡이 앨범의 타이틀곡인지 나타냅니다.
    let isTitleTrack: Bool

    /// Apple Music, YouTube Music, Spotify, Melon의 곡 ID입니다.
    let platformIDs: MusicPlatformIDsDTO

    /// Swift의 `ID` 표기와 JSON의 `Ids` 표기 차이를 연결합니다.
    enum CodingKeys: String, CodingKey {
        case id, isTitleTrack
        case artistIDs = "artistIds"
        case platformIDs = "platformIds"
    }
}

// MARK: - 플랫폼별 카탈로그 식별자

/// 외부 음악 플랫폼에서 앨범 또는 곡을 찾는 데 사용하는 ID 모음입니다.
/// 확인되지 않았거나 제공되지 않는 플랫폼의 값은 `nil`입니다.
nonisolated struct MusicPlatformIDsDTO: Decodable, Sendable {
    /// Apple Music의 앨범 또는 곡 ID입니다.
    let appleMusic: String?

    /// YouTube Music의 앨범 재생목록 ID 또는 곡 영상 ID입니다.
    let youtubeMusic: String?

    /// Spotify의 앨범 또는 트랙 ID입니다.
    let spotify: String?

    /// Melon의 앨범 또는 곡 ID입니다.
    let melon: String?
}

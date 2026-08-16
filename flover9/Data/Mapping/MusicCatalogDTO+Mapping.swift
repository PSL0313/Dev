import Foundation

extension MusicCatalogDTO {
    /// 디코딩한 전체 카탈로그 DTO를 Domain Entity로 변환합니다.
    nonisolated func toEntity() -> MusicCatalogEntity {
        MusicCatalogEntity(
            schemaVersion: schemaVersion,
            albums: albums.map { $0.toEntity() }
        )
    }
}

extension MusicAlbumDTO {
    /// 앨범 DTO와 그 수록곡을 Domain Entity로 변환합니다.
    nonisolated func toEntity() -> MusicAlbumEntity {
        MusicAlbumEntity(
            id: id,
            artistIDs: artistIDs,
            platformIDs: platformIDs.toEntity(),
            tracks: tracks.map { $0.toEntity() }
        )
    }
}

extension MusicTrackDTO {
    /// 곡 DTO를 Domain Entity로 변환합니다.
    nonisolated func toEntity() -> MusicTrackEntity {
        MusicTrackEntity(
            id: id,
            artistIDs: artistIDs,
            isTitleTrack: isTitleTrack,
            platformIDs: platformIDs.toEntity()
        )
    }
}

extension MusicPlatformIDsDTO {
    /// 플랫폼별 ID DTO를 Domain Entity로 변환합니다.
    nonisolated func toEntity() -> MusicPlatformIDsEntity {
        MusicPlatformIDsEntity(
            appleMusic: appleMusic,
            youtubeMusic: youtubeMusic,
            spotify: spotify,
            melon: melon
        )
    }
}

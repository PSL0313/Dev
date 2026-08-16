import Foundation

/// 앱 번들에서 음악 카탈로그를 읽고 앨범을 조회하는 저장소의 규약입니다.
///
/// 구현체는 내부 저장 구조를 노출하지 않으며, 호출자는 제공되는 조회 함수만 사용합니다.
protocol MusicAlbumStoreProtocol: Sendable {
    /// 정규 앨범과 기타 참여 앨범 JSON을 읽어 저장소를 구성합니다.
    func load() async throws

    /// 앱 내부 앨범 ID와 일치하는 앨범을 반환합니다.
    /// - Parameter id: 조회할 앨범의 내부 고유 ID입니다.
    func album(id: MusicAlbumEntity.ID) async -> MusicAlbumEntity?

    /// 프로미스나인의 정규 앨범을 JSON 순서대로 반환합니다.
    func albums() async -> [MusicAlbumEntity]

    /// OST와 협업 등 기타 참여 앨범을 JSON 순서대로 반환합니다.
    func otherAlbums() async -> [MusicAlbumEntity]
}

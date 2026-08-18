import Foundation

/// 앱 번들에 포함된 음악 카탈로그 JSON을 메모리에 보관하는 저장소입니다.
///
/// `actor`로 선언되어 여러 비동기 작업에서 동시에 접근해도 내부 상태가 안전하게 보호됩니다.
/// 앨범 딕셔너리와 정렬용 ID 배열은 외부에 공개하지 않고 조회 함수로만 제공합니다.
actor MusicAlbumStore: MusicAlbumStoreProtocol {
    /// 카탈로그 JSON 파일을 찾을 번들입니다.
    private let bundle: Bundle

    /// 내부 앨범 ID를 키로 사용해 빠르게 앨범을 찾는 딕셔너리입니다.
    private var albumByID: [MusicAlbumEntity.ID: MusicAlbumEntity] = [:]

    /// 프로미스나인 정규 앨범의 JSON상 순서를 보존하는 ID 배열입니다.
    private var orderedAlbumIDs: [MusicAlbumEntity.ID] = []

    /// OST와 협업 등 기타 참여 앨범의 JSON상 순서를 보존하는 ID 배열입니다.
    private var orderedOtherAlbumIDs: [MusicAlbumEntity.ID] = []

    /// 음악 카탈로그 저장소를 생성합니다.
    /// - Parameter bundle: JSON을 읽을 번들입니다. 기본값은 앱의 메인 번들입니다.
    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    /// 정규 앨범과 기타 참여 앨범 JSON을 읽어 내부 저장소를 구성합니다.
    ///
    /// 같은 ID의 앨범이 두 카탈로그에 중복되면 딕셔너리 생성 과정에서 오류가 발생하므로,
    /// 모든 내부 앨범 ID는 두 JSON 파일 전체에서 고유해야 합니다.
    func load() {
        let groupCatalog = loadCatalog(resource: "fromis9-albums")
        let otherCatalog = loadCatalog(resource: "fromis9-others")

        albumByID = Dictionary(
            uniqueKeysWithValues: (groupCatalog.albums + otherCatalog.albums).map { ($0.id, $0) }
        )
        orderedAlbumIDs = groupCatalog.albums.map(\.id).reversed()
        orderedOtherAlbumIDs = otherCatalog.albums.map(\.id).reversed()
    }

    /// 앱 내부 앨범 ID로 앨범 한 개를 조회합니다.
    /// - Parameter id: 조회할 앨범의 내부 고유 ID입니다.
    /// - Returns: 일치하는 앨범이 없으면 `nil`입니다.
    func album(id: MusicAlbumEntity.ID) -> MusicAlbumEntity? {
        if albumByID[id] == nil {
            load()
        }
        return albumByID[id]
    }

    /// 프로미스나인의 정규 앨범을 JSON에 기록된 순서대로 반환합니다.
    func albums() -> [MusicAlbumEntity] {
        if orderedAlbumIDs.isEmpty {
            load()
        }
        return orderedAlbumIDs.compactMap { albumByID[$0] }
    }

    /// OST와 협업 등 기타 참여 앨범을 JSON에 기록된 순서대로 반환합니다.
    func otherAlbums() -> [MusicAlbumEntity] {
        if orderedOtherAlbumIDs.isEmpty {
            load()
        }
        return orderedOtherAlbumIDs.compactMap { albumByID[$0] }
    }

    /// 번들에서 지정한 JSON을 읽고 Domain Entity로 변환합니다.
    /// - Parameter resource: 확장자를 제외한 JSON 리소스 이름입니다.
    /// - Returns: 디코딩과 매핑을 마친 음악 카탈로그입니다.
    private func loadCatalog(resource: String) -> MusicCatalogEntity {
        do {
            let fileURL = bundle.url(forResource: resource, withExtension: "json")!
            
            let data = try Data(contentsOf: fileURL)
            let dto = try JSONDecoder().decode(MusicCatalogDTO.self, from: data)
            return dto.toEntity()
        } catch {
            fatalError()
        }
    }
}

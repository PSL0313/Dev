import MapKit

// MKMapItem은 변경 가능한 참조 타입이므로 접근을 MainActor에 한정한다.
// 캐시 actor에는 이 격리된 참조만 전달하며, MKMapItem에 Sendable을 강제하지 않는다.
@MainActor
final class MapItemCacheValue {
    let mapItem: MKMapItem

    init(_ mapItem: MKMapItem) {
        self.mapItem = mapItem
    }
}

// 같은 일정/이벤트 ID라도 위치 정보가 바뀌면 이전 생성 결과를 재사용하지 않는다.
nonisolated struct MapItemLocationKey: Hashable, Sendable {
    let latitude: Double
    let longitude: Double
    let name: String?
    let roadAddress: String?
}

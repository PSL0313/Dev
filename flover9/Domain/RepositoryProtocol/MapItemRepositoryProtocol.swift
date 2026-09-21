import MapKit

@MainActor
protocol MapItemRepositoryProtocol {
    func fetchMapItem(applePlaceID: String) async throws -> MKMapItem
    func makeMapItem(id: UUID, location: CLLocation, name: String?, roadAddress: String?) async throws -> MKMapItem
    func reset(id: UUID, applePlaceID: String?) async
    func resetAll() async
}

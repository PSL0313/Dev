import Foundation
import MapKit
import Testing
@testable import flover9

@Suite("Map item priority and memory cache")
@MainActor
struct MapItemUseCaseTests {
    private let location = CLLocation(latitude: 37.5, longitude: 127.0)

    @Test("Apple 조회 결과를 우선하고 같은 Place ID는 다른 일정에서도 공유한다")
    func placeIDPriorityAndSharing() async throws {
        let source = MapItemFixtureDataSource()
        let useCase = makeUseCase(source)
        let first = try await useCase.execute(id: UUID(), location: location, applePlaceID: " place-a ")
        let second = try await useCase.execute(id: UUID(), location: location, applePlaceID: "place-a")
        #expect(first === source.appleItem)
        #expect(second === source.appleItem)
        #expect(source.placeIDs == ["place-a"])
        #expect(source.makeCalls == 0)
    }

    @Test("Place ID가 없으면 ID별 좌표 결과를 재사용한다")
    func coordinateCaching() async throws {
        let source = MapItemFixtureDataSource()
        let useCase: MapItemUseCaseProtocol = makeUseCase(source)
        let id = UUID()
        let first = try await useCase.execute(id: id, location: location, applePlaceID: nil)
        let second = try await useCase.execute(id: id, location: location, applePlaceID: " \n")
        #expect(first === second)
        #expect(first?.location.coordinate.latitude == 37.5)
        #expect(source.placeIDs.isEmpty)
        #expect(source.makeCalls == 1)
    }

    @Test("좌표 캐시가 있어도 Place ID 조회를 다시 시도하여 더 높은 우선순위 결과로 전환한다")
    func fallbackDoesNotHidePlaceID() async throws {
        let source = MapItemFixtureDataSource()
        source.lookupError = MapItemError.lookupFailed
        let useCase = makeUseCase(source)
        let id = UUID()
        let fallback = try await useCase.execute(id: id, location: location, applePlaceID: "place-a")
        let cachedFallback = try await useCase.execute(id: id, location: location, applePlaceID: "place-a")
        #expect(fallback === cachedFallback)
        #expect(source.makeCalls == 1)

        source.lookupError = nil
        let resolved = try await useCase.execute(id: id, location: location, applePlaceID: "place-a")
        #expect(resolved === source.appleItem)
        #expect(resolved !== fallback)
        #expect(source.placeIDs.count == 3)
        #expect(source.makeCalls == 1)
    }

    @Test("같은 ID라도 좌표나 장소 정보가 바뀌면 다시 생성한다")
    func changedLocation() async throws {
        let source = MapItemFixtureDataSource()
        let useCase = makeUseCase(source)
        let id = UUID()
        let first = try await useCase.makeMapItem(id: id, location: location, name: "A", roadAddress: "Road A")
        let moved = try await useCase.makeMapItem(id: id, location: CLLocation(latitude: 38, longitude: 128), name: "A", roadAddress: "Road A")
        let renamed = try await useCase.makeMapItem(id: id, location: location, name: "B", roadAddress: "Road B")
        #expect(first !== moved)
        #expect(first !== renamed)
        #expect(moved.location.coordinate.latitude == 38)
        #expect(renamed.name == "B")
        #expect(source.makeCalls == 3)
    }

    @Test("좌표가 같아도 서로 다른 일정 ID의 장소 정보를 섞지 않는다")
    func separateIDs() async throws {
        let source = MapItemFixtureDataSource()
        let useCase = makeUseCase(source)
        let first = try await useCase.makeMapItem(id: UUID(), location: location, name: "A")
        let second = try await useCase.makeMapItem(id: UUID(), location: location, name: "B")
        #expect(first !== second)
        #expect(first.name == "A" && second.name == "B")
        #expect(source.makeCalls == 2)
    }

    @Test("Place ID가 바뀌면 이전 Apple 조회 결과를 사용하지 않는다")
    func changedPlaceID() async throws {
        let source = MapItemFixtureDataSource()
        let useCase = makeUseCase(source)
        let id = UUID()
        _ = try await useCase.execute(id: id, location: location, applePlaceID: "place-a")
        _ = try await useCase.execute(id: id, location: location, applePlaceID: "place-b")
        #expect(source.placeIDs == ["place-a", "place-b"])
    }

    @Test("좌표가 없어도 Place ID만으로 조회할 수 있다")
    func placeIDWithoutCoordinate() async throws {
        let source = MapItemFixtureDataSource()
        let useCase = makeUseCase(source)
        let result = try await useCase.execute(id: UUID(), location: nil, applePlaceID: "place-a")
        #expect(result === source.appleItem)
        #expect(source.makeCalls == 0)
    }

    @Test("사용할 위치가 없거나 좌표가 잘못되면 항목을 만들지 않는다")
    func unavailableLocation() async throws {
        let source = MapItemFixtureDataSource()
        let useCase = makeUseCase(source)
        #expect(try await useCase.execute(id: UUID(), location: nil, applePlaceID: nil) == nil)
        #expect(try await useCase.execute(id: UUID(), location: CLLocation(latitude: 91, longitude: 127), applePlaceID: nil) == nil)
        source.lookupError = MapItemError.lookupFailed
        #expect(try await useCase.execute(id: UUID(), location: nil, applePlaceID: "place-a") == nil)
        #expect(source.makeCalls == 0)
    }

    @Test("잘못된 좌표의 직접 생성 요청은 캐시에도 저장하지 않는다")
    func invalidCoordinate() async throws {
        let source = MapItemFixtureDataSource()
        let useCase = makeUseCase(source)
        await #expect(throws: MapItemError.invalidCoordinate) {
            _ = try await useCase.makeMapItem(id: UUID(), location: CLLocation(latitude: .nan, longitude: 0))
        }
        #expect(source.makeCalls == 0)
    }

    @Test("Apple 조회 취소는 좌표 생성으로 전환하지 않는다")
    func cancellation() async throws {
        let source = MapItemFixtureDataSource()
        source.lookupError = CancellationError()
        let useCase = makeUseCase(source)
        await #expect(throws: CancellationError.self) {
            _ = try await useCase.execute(id: UUID(), location: location, applePlaceID: "place-a")
        }
        #expect(source.makeCalls == 0)
        source.lookupError = nil
        _ = try await useCase.execute(id: UUID(), location: location, applePlaceID: "place-a")
        #expect(source.placeIDs.count == 2)
    }

    @Test("선택 초기화는 해당 키만 지우고 전체 초기화는 양쪽 캐시를 지운다")
    func reset() async throws {
        let source = MapItemFixtureDataSource()
        let useCase = makeUseCase(source)
        let id = UUID()
        let otherID = UUID()
        _ = try await useCase.makeMapItem(id: id, location: location)
        _ = try await useCase.makeMapItem(id: otherID, location: location)
        _ = try await useCase.fetchMapItem(applePlaceID: "place-a")
        _ = try await useCase.fetchMapItem(applePlaceID: "place-b")
        await useCase.reset(id: id, applePlaceID: " place-a ")
        _ = try await useCase.makeMapItem(id: id, location: location)
        _ = try await useCase.makeMapItem(id: otherID, location: location)
        _ = try await useCase.fetchMapItem(applePlaceID: "place-a")
        _ = try await useCase.fetchMapItem(applePlaceID: "place-b")
        #expect(source.makeCalls == 3)
        #expect(source.placeIDs.count == 3)
        await useCase.resetAll()
        _ = try await useCase.makeMapItem(id: otherID, location: location)
        _ = try await useCase.fetchMapItem(applePlaceID: "place-b")
        #expect(source.makeCalls == 4)
        #expect(source.placeIDs.count == 4)
    }

    @Test("초기화 전 시작된 Apple 요청이 캐시를 되살리지 않는다")
    func resetDuringLookup() async throws {
        let source = MapItemFixtureDataSource()
        let useCase = makeUseCase(source)
        source.beforeLookupReturns = { await useCase.resetAll() }
        _ = try await useCase.fetchMapItem(applePlaceID: "place-a")
        source.beforeLookupReturns = nil
        _ = try await useCase.fetchMapItem(applePlaceID: "place-a")
        #expect(source.placeIDs.count == 2)
    }

    @Test("새 캐시는 이전 인스턴스의 조회 결과를 갖지 않는다")
    func lifetime() async throws {
        let source = MapItemFixtureDataSource()
        _ = try await makeUseCase(source).fetchMapItem(applePlaceID: "place-a")
        _ = try await makeUseCase(source).fetchMapItem(applePlaceID: "place-a")
        #expect(source.placeIDs.count == 2)
    }

    @Test("실제 DataSource는 좌표와 장소명, 주소로 MKMapItem을 생성한다")
    func realCoordinateDataSource() throws {
        let source = AppleMapItemDataSource()
        let item = try source.makeMapItem(location: location, name: "Venue", roadAddress: "Road 1")
        #expect(item.location.coordinate.latitude == 37.5)
        #expect(item.location.coordinate.longitude == 127)
        #expect(item.name == "Venue")
        #expect(item.address != nil)
        #expect(throws: MapItemError.invalidCoordinate) {
            try source.makeMapItem(location: CLLocation(latitude: 91, longitude: 0), name: nil, roadAddress: nil)
        }
    }

    private func makeUseCase(_ source: MapItemFixtureDataSource) -> MapItemUseCase {
        MapItemUseCase(repository: MapItemRepository(dataSource: source, cache: MapItemCache()))
    }
}

@MainActor
private final class MapItemFixtureDataSource: MapItemDataSourceProtocol {
    let appleItem = MKMapItem(location: CLLocation(latitude: 37.6, longitude: 127.1), address: nil)
    var lookupError: Error?
    var beforeLookupReturns: (() async -> Void)?
    private(set) var placeIDs: [String] = []
    private(set) var makeCalls = 0

    func fetchMapItem(applePlaceID: String) async throws -> MKMapItem {
        placeIDs.append(applePlaceID)
        if let lookupError { throw lookupError }
        await beforeLookupReturns?()
        return appleItem
    }

    func makeMapItem(location: CLLocation, name: String?, roadAddress: String?) throws -> MKMapItem {
        makeCalls += 1
        return try AppleMapItemDataSource().makeMapItem(location: location, name: name, roadAddress: roadAddress)
    }
}

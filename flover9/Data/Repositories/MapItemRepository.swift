//
//  MapItemRepository.swift
//  flover9
//
//  Created by 박선린 on 9/16/26.
//
import MapKit

// MARK: - Apple 조회 결과와 좌표 생성 결과를 각각 캐싱하는 저장소
@MainActor
final class MapItemRepository: MapItemRepositoryProtocol {
    private let dataSource: MapItemDataSourceProtocol
    private let cache: MapItemCacheProtocol
    private var cacheGeneration: UInt = 0

    init(dataSource: MapItemDataSourceProtocol, cache: MapItemCacheProtocol) {
        self.dataSource = dataSource
        self.cache = cache
    }

    func fetchMapItem(applePlaceID: String) async throws -> MKMapItem {
        try Task.checkCancellation()
        let placeID = applePlaceID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !placeID.isEmpty else { throw MapItemError.invalidPlaceID }

        let generation = cacheGeneration
        if let cached = await cache.placeMapItem(for: placeID) {
            try Task.checkCancellation()
            return cached.mapItem
        }

        do {
            let mapItem = try await dataSource.fetchMapItem(applePlaceID: placeID)
            try Task.checkCancellation()
            if generation == cacheGeneration {
                await cache.savePlaceMapItem(MapItemCacheValue(mapItem), for: placeID)
            }
            return mapItem
        } catch {
            try Task.checkCancellation()
            if error is CancellationError { throw CancellationError() }
            if let error = error as? MapItemError { throw error }
            throw MapItemError.lookupFailed
        }
    }

    func makeMapItem(
        id: UUID,
        location: CLLocation,
        name: String? = nil,
        roadAddress: String? = nil
    ) async throws -> MKMapItem {
        try Task.checkCancellation()
        guard CLLocationCoordinate2DIsValid(location.coordinate) else {
            throw MapItemError.invalidCoordinate
        }
        let locationKey = MapItemLocationKey(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            name: name,
            roadAddress: roadAddress
        )
        let generation = cacheGeneration
        if let cached = await cache.coordinateMapItem(for: id, locationKey: locationKey) {
            try Task.checkCancellation()
            return cached.mapItem
        }

        try Task.checkCancellation()
        let mapItem = try dataSource.makeMapItem(location: location, name: name, roadAddress: roadAddress)
        if generation == cacheGeneration {
            await cache.saveCoordinateMapItem(MapItemCacheValue(mapItem), for: id, locationKey: locationKey)
        }
        return mapItem
    }

    func reset(id: UUID, applePlaceID: String?) async {
        cacheGeneration &+= 1
        await cache.reset(
            id: id,
            applePlaceID: applePlaceID?.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    func resetAll() async {
        cacheGeneration &+= 1
        await cache.resetAll()
    }
}

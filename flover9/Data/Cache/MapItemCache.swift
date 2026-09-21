//
//  MapItemCache.swift
//  flover9
//
//  Created by 박선린 on 9/16/26.
//
import Foundation

// MARK: - 앱 실행 중에만 유지하는 지도 항목 메모리 캐시
actor MapItemCache: MapItemCacheProtocol {
    private var itemsByPlaceID: [String: MapItemCacheValue] = [:]
    private var itemsByID: [UUID: CoordinateEntry] = [:]

    private struct CoordinateEntry {
        let locationKey: MapItemLocationKey
        let value: MapItemCacheValue
    }

    func placeMapItem(for applePlaceID: String) -> MapItemCacheValue? {
        itemsByPlaceID[applePlaceID]
    }

    func coordinateMapItem(for id: UUID, locationKey: MapItemLocationKey) -> MapItemCacheValue? {
        guard let entry = itemsByID[id], entry.locationKey == locationKey else {
            return nil
        }
        return entry.value
    }

    func savePlaceMapItem(_ value: MapItemCacheValue, for applePlaceID: String) {
        itemsByPlaceID[applePlaceID] = value
    }

    // 좌표로 생성한 값은 Place ID 캐시에 넣지 않는다.
    func saveCoordinateMapItem(_ value: MapItemCacheValue, for id: UUID, locationKey: MapItemLocationKey) {
        itemsByID[id] = CoordinateEntry(locationKey: locationKey, value: value)
    }

    func reset(id: UUID, applePlaceID: String?) {
        itemsByID[id] = nil
        if let applePlaceID {
            itemsByPlaceID[applePlaceID] = nil
        }
    }

    func resetAll() {
        itemsByPlaceID.removeAll()
        itemsByID.removeAll()
    }
}

//
//  MapItemCacheProtocol.swift
//  flover9
//
//  Created by 박선린 on 9/16/26.
//
import Foundation

protocol MapItemCacheProtocol: Actor {
    func placeMapItem(for applePlaceID: String) -> MapItemCacheValue?
    func coordinateMapItem(for id: UUID, locationKey: MapItemLocationKey) -> MapItemCacheValue?

    func savePlaceMapItem(_ value: MapItemCacheValue, for applePlaceID: String)
    func saveCoordinateMapItem(_ value: MapItemCacheValue, for id: UUID, locationKey: MapItemLocationKey)

    func reset(id: UUID, applePlaceID: String?)
    func resetAll()
}

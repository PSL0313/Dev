//
//  AppleMapItemDataSource.swift
//  flover9
//
//  Created by 박선린 on 9/16/26.
//
import MapKit

// MARK: - MapKit 조회 및 좌표 기반 MKMapItem 생성
@MainActor
final class AppleMapItemDataSource: MapItemDataSourceProtocol {
    func fetchMapItem(applePlaceID: String) async throws -> MKMapItem {
        try Task.checkCancellation()
        guard !applePlaceID.isEmpty,
              let identifier = MKMapItem.Identifier(rawValue: applePlaceID) else {
            throw MapItemError.invalidPlaceID
        }

        let request = MKMapItemRequest(mapItemIdentifier: identifier)
        let mapItem = try await request.mapItem
        try Task.checkCancellation()
        return mapItem
    }

    func makeMapItem(location: CLLocation, name: String?, roadAddress: String?) throws -> MKMapItem {
        guard CLLocationCoordinate2DIsValid(location.coordinate) else {
            throw MapItemError.invalidCoordinate
        }
        let address = roadAddress.flatMap { MKAddress(fullAddress: $0, shortAddress: name) }
        let mapItem = MKMapItem(location: location, address: address)
        mapItem.name = name
        return mapItem
    }
}

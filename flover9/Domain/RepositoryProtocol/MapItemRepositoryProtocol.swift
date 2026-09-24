//
//  MapItemRepositoryProtocol.swift
//  flover9
//
//  Created by 박선린 on 9/24/26.
//

import MapKit

@MainActor
protocol MapItemRepositoryProtocol {
    func fetchMapItem(applePlaceID: String) async throws -> MKMapItem
    func makeMapItem(id: UUID, location: CLLocation, name: String?, roadAddress: String?) async throws -> MKMapItem
    func reset(id: UUID, applePlaceID: String?) async
    func resetAll() async
}

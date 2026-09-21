//
//  MapItemDataSourceProtocol.swift
//  flover9
//
//  Created by 박선린 on 9/16/26.
//

import MapKit

@MainActor
protocol MapItemDataSourceProtocol {
    func fetchMapItem(applePlaceID: String) async throws -> MKMapItem
    func makeMapItem(location: CLLocation, name: String?, roadAddress: String?) throws -> MKMapItem
}

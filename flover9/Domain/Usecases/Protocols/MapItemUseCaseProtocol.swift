//
//  MapItemUseCaseProtocol.swift
//  flover9
//
//  Created by 박선린 on 9/16/26.
//
import MapKit

@MainActor
protocol MapItemUseCaseProtocol {
    /// Place ID 조회를 우선하고, 사용할 수 없으면 좌표로 생성한다.
    func execute(id: UUID, location: CLLocation?, applePlaceID: String?, name: String?, roadAddress: String?) async throws -> MKMapItem?
    func fetchMapItem(applePlaceID: String) async throws -> MKMapItem
    func makeMapItem(id: UUID, location: CLLocation, name: String?, roadAddress: String?) async throws -> MKMapItem
    func reset(id: UUID, applePlaceID: String?) async
    func resetAll() async
}

extension MapItemUseCaseProtocol {
    // 장소명과 주소가 필요하지 않은 호출부는 세 가지 값만 전달한다.
    func execute(id: UUID, location: CLLocation?, applePlaceID: String?) async throws -> MKMapItem? {
        try await execute(id: id, location: location, applePlaceID: applePlaceID, name: nil, roadAddress: nil)
    }

    func makeMapItem(id: UUID, location: CLLocation) async throws -> MKMapItem {
        try await makeMapItem(id: id, location: location, name: nil, roadAddress: nil)
    }
}

//
//  MapItemUseCase.swift
//  flover9
//
//  Created by 박선린 on 9/16/26.
//
import MapKit

// MARK: - 지도 항목의 조회 우선순위를 결정하는 UseCase
@MainActor
final class MapItemUseCase: MapItemUseCaseProtocol {
    private let repository: MapItemRepositoryProtocol

    init(repository: MapItemRepositoryProtocol) {
        self.repository = repository
    }

    func execute(
        id: UUID,
        location: CLLocation?,
        applePlaceID: String?,
        name: String? = nil,
        roadAddress: String? = nil
    ) async throws -> MKMapItem? {
        try Task.checkCancellation()
        if let placeID = applePlaceID?.trimmingCharacters(in: .whitespacesAndNewlines), !placeID.isEmpty {
            do {
                return try await fetchMapItem(applePlaceID: placeID)
            } catch {
                // 취소는 조회 실패와 다르므로 좌표 생성으로 이어지지 않는다.
                try Task.checkCancellation()
                if error is CancellationError { throw CancellationError() }
            }
        }

        guard let location, CLLocationCoordinate2DIsValid(location.coordinate) else {
            return nil
        }
        return try await makeMapItem(id: id, location: location, name: name, roadAddress: roadAddress)
    }

    func fetchMapItem(applePlaceID: String) async throws -> MKMapItem {
        try await repository.fetchMapItem(applePlaceID: applePlaceID)
    }

    func makeMapItem(
        id: UUID,
        location: CLLocation,
        name: String? = nil,
        roadAddress: String? = nil
    ) async throws -> MKMapItem {
        try await repository.makeMapItem(id: id, location: location, name: name, roadAddress: roadAddress)
    }

    func reset(id: UUID, applePlaceID: String?) async {
        await repository.reset(id: id, applePlaceID: applePlaceID)
    }

    func resetAll() async {
        await repository.resetAll()
    }
}

//
//  MapItemError.swift
//  flover9
//
//  Created by 박선린 on 9/10/26.
//
// MARK: - 지도 항목 조회 및 생성 오류
nonisolated enum MapItemError: Error, Equatable, Sendable {
    case invalidPlaceID
    case invalidCoordinate
    case lookupFailed
}

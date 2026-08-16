//
//  AppleMusicAuthorizationService.swift
//  flover9
//
//  Created by 박선린 on 8/16/26.
//

import MusicKit

nonisolated enum AppleMusicAuthorizationError: Error, Sendable {
    case denied
    case restricted
    case unavailable
}

nonisolated struct AppleMusicAuthorizationService: Sendable {
    /// MusicKit 사용 권한을 확인하고 필요한 경우 사용자에게 요청합니다.
    func requestAuthorization() async throws {
        let status: MusicAuthorization.Status

        switch MusicAuthorization.currentStatus {
        case .notDetermined:
            status = await MusicAuthorization.request()

        case let currentStatus:
            status = currentStatus
        }

        switch status {
        case .authorized:
            return

        case .denied:
            throw AppleMusicAuthorizationError.denied

        case .restricted:
            throw AppleMusicAuthorizationError.restricted

        case .notDetermined:
            throw AppleMusicAuthorizationError.unavailable

        @unknown default:
            throw AppleMusicAuthorizationError.unavailable
        }
    }
}

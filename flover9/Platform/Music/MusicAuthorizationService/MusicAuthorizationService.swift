//
//  MusicAuthorizationService.swift
//  flover9
//
//  Created by 박선린 on 9/1/26.
//


import MusicKit

enum MusicAuthorizationState {
    case granted            //통과
    case requestRequired    // 요청 필요
    case denied             // 이미 거절
    case unavailable        // 불가능(기기 제한 혹은 이외의 불가능한 상황에 사용)
}

final class MusicAuthorizationService: MusicAuthorizationServiceProtocol {
    
    var currentStatus: MusicAuthorization.Status {
        MusicAuthorization.currentStatus
    }
    
    var canRequestAuthorization: MusicAuthorizationState {
        switch currentStatus {
        case .authorized:   // 수락 완료
            return .granted
        case .notDetermined:
            return .requestRequired
        case .denied:
            return .unavailable
        case .restricted:
            return .unavailable
        @unknown default:
            return .unavailable
        }
    }

    
    func requestAuthorization() async -> MusicAuthorizationState {
        _ = await MusicAuthorization.request()
        return canRequestAuthorization
        
    }
}

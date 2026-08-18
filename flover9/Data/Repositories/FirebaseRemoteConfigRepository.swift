//
//  FirebaseRemoteConfigRepository.swift
//  flover9
//
//  Created by 박선린 on 8/3/26.
//


import Foundation
import FirebaseRemoteConfig

// MARK: - Firebase Remote Config를 이용한 운영 설정 저장소
final class FirebaseRemoteConfigRepository: RemoteConfigRepositoryProtocol {
    private let remoteConfig: RemoteConfig // Firebase 원격 설정 객체

    init() {
        self.remoteConfig = .remoteConfig() // 원격 설정 객체 보관
        
        let settings = RemoteConfigSettings()
#if DEBUG
        settings.minimumFetchInterval = 0
#else
        settings.minimumFetchInterval = 3_600   // 한시간, 설정값 단위: 1 == 1초
#endif
            remoteConfig.configSettings = settings
        
        remoteConfig.setDefaults([
            "maintenance_mode": false as NSNumber,
            "maintenance_message":
                "현재 서비스 점검 중입니다." as NSString,
            "minimum_app_version": "1.0.0" as NSString
        ]) // 네트워크 실패 등에 대비한 앱 기본값
    }

    func fetchAppAvailability() async -> AppAvailability {
        do {
            try await remoteConfig.fetchAndActivate() // 최신 설정 조회 및 활성화
            
            return makeAppAvailability() // 활성화된 값을 Domain 결과로 변환
        } catch {
            let mappedError = mapRemoteConfigError(error) // 오류 분류

            print("Remote Config 오류:", mappedError) // 이후 Crashlytics 기록
        }
        return makeAppAvailability()
    }
    
}

private extension FirebaseRemoteConfigRepository {
    // MARK: - 활성화된 원격 설정으로 앱 운영 상태 생성
    func makeAppAvailability() -> AppAvailability {
        let maintenanceMode =
            remoteConfig["maintenance_mode"].boolValue // 점검 여부

        let fetchedMaintenanceMessage =
            remoteConfig["maintenance_message"].stringValue // 원격 점검 문구

        let maintenanceMessage =
            fetchedMaintenanceMessage.isEmpty
            ? "현재 서비스 점검 중입니다."
            : fetchedMaintenanceMessage // 빈 값이면 앱 기본 문구 사용

        let fetchedMinimumVersion =
            remoteConfig["minimum_app_version"].stringValue // 원격 최소 버전

        let minimumVersion =
            fetchedMinimumVersion.isEmpty
            ? "1.0.0"
            : fetchedMinimumVersion // 빈 값이면 앱 기본 버전 사용

        if maintenanceMode {
            return .maintenance(
                message: maintenanceMessage
            ) // 점검 상태 반환
        }

        let currentVersion =
            Bundle.main.object(
                forInfoDictionaryKey: "CFBundleShortVersionString"
            ) as? String ?? "1.0.0" // 현재 앱 버전

        if currentVersion.compare(
            minimumVersion,
            options: .numeric
        ) == .orderedAscending {
            return .updateRequired(
                minimumVersion: minimumVersion
            ) // 강제 업데이트 필요
        }

        return .available // 정상 이용 가능
    }
    
    // MARK: - 모든 외부 오류의 분류 순서를 결정하는 진입점
    func mapRemoteConfigError(
        _ error: Error
    ) -> AppAvailabilityError {
        if let firebaseError = error as? RemoteConfigError {
            return mapFirebaseError(firebaseError) // Firebase 오류 처리
        }

        let nsError = error as NSError

        if nsError.domain == NSURLErrorDomain {
            return mapNetworkError(nsError) // 네트워크 오류 처리
        }

        return .unknown // 분류하지 못한 오류
    }

    // MARK: - Firebase Remote Config 오류를 Domain 오류로 변환
    func mapFirebaseError(
        _ error: RemoteConfigError
    ) -> AppAvailabilityError {
        switch error.code {
        case .throttled:
            return .fetchFailed // 요청 횟수 제한

        case .internalError:
            return .serverUnavailable // Firebase 내부 오류

        default:
            return .unknown // 분류되지 않은 Firebase 오류
        }
    }

    // MARK: - 네트워크 NSError를 Domain 오류로 변환
    func mapNetworkError(
        _ error: NSError
    ) -> AppAvailabilityError {
        switch error.code {
        case NSURLErrorNotConnectedToInternet,
             NSURLErrorNetworkConnectionLost:
            return .networkUnavailable // 네트워크 연결 없음

        case NSURLErrorTimedOut,
             NSURLErrorCannotFindHost,
             NSURLErrorCannotConnectToHost,
             NSURLErrorDNSLookupFailed:
            return .serverUnavailable // 서버 연결 실패

        default:
            return .fetchFailed // 그 밖의 URL 요청 오류
        }
    }
}

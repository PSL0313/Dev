//
//  FirebaseErrorLogger.swift
//  flover9
//
//  Created by 박선린 on 8/4/26.
//


import FirebaseAnalytics
import FirebaseCrashlytics
import Foundation

// MARK: - Domain 오류를 Firebase Analytics와 Crashlytics에 기록
final class FirebaseErrorLogger: ErrorLogging, @unchecked Sendable {

    func record(_ error: AuthError) async {
        switch error {
        case .cancelled:
            return                              // 사용자 취소는 기록하지 않음

        case .sessionExpired,
             .networkUnavailable:
            logAnalytics(error)                 // 예상 가능한 운영 오류

        case .unknown:
            recordCrashlytics(error)            // 원인 분석이 필요한 오류

        case .invalidAppleCredential,
             .serverUnavailable,
             .accountDeletionFailed:
            logAnalytics(error)                 // 발생 빈도 기록
            recordCrashlytics(error)            // 상세 원인 기록

        case .unauthenticated:
            logAnalytics(error)                 // 인증 상태 이상 기록
        }
    }

    func record(_ error: ProfileError) async {
        switch error {
        case .invalidNickname:
            return                              // 사용자 입력 오류는 기록하지 않음

        case .nicknameAlreadyExists,
             .networkUnavailable:
            logAnalytics(error)                 // 발생 빈도 기록

        case .invalidRole,
             .invalidProfileData,
             .unknown:
            recordCrashlytics(error)            // 개발자가 조사할 오류

        case .notFound,
             .permissionDenied,
             .serverUnavailable:
            logAnalytics(error)                 // 사용자 영향 빈도 기록
            recordCrashlytics(error)            // 오류 상세 기록

        case .unauthenticated:
            logAnalytics(error)                 // 세션 상태 이상 기록
        }
    }

    func record(_ error: MediaUploadError) async {
        switch error {
        case .emptyMedia,
             .invalidFile,
             .unsupportedMediaType,
             .fileTooLarge,
             .duplicatedSortOrder:
            return                              // 사용자 입력 단계에서 안내할 오류

        case .unauthenticated,
             .permissionDenied,
             .networkUnavailable,
             .cleanupPending:
            logAnalytics(error)                 // 운영 상태와 발생 빈도 기록

        case .uploadFailed,
             .finalizationFailed,
             .serverUnavailable,
             .unknown:
            logAnalytics(error)
            recordCrashlytics(error)            // 서버/R2 계약 오류 상세 기록
        }
    }
}

private extension FirebaseErrorLogger {

    // MARK: - 인증 오류 발생 횟수를 Analytics 이벤트로 기록
    func logAnalytics(_ error: AuthError) {
        Analytics.logEvent(
            "auth_error",
            parameters: [
                "error_type": String(describing: error)
            ]
        )
    }

    // MARK: - 프로필 오류 발생 횟수를 Analytics 이벤트로 기록
    func logAnalytics(_ error: ProfileError) {
        Analytics.logEvent(
            "profile_error",
            parameters: [
                "error_type": String(describing: error)
            ]
        )
    }

    // MARK: - 미디어 업로드 오류 발생 횟수를 Analytics 이벤트로 기록
    func logAnalytics(_ error: MediaUploadError) {
        Analytics.logEvent(
            "media_upload_error",
            parameters: [
                "error_type": String(describing: error)
            ]
        )
    }

    // MARK: - 인증 오류의 상세 내용을 Crashlytics에 기록
    func recordCrashlytics(_ error: AuthError) {
        Crashlytics.crashlytics().record(
            error: NSError(
                domain: "Flover9.Auth",
                code: errorCode(for: error),
                userInfo: [
                    NSLocalizedDescriptionKey: error.userMessage
                ]
            )
        )
    }

    // MARK: - 프로필 오류의 상세 내용을 Crashlytics에 기록
    func recordCrashlytics(_ error: ProfileError) {
        Crashlytics.crashlytics().record(
            error: NSError(
                domain: "Flover9.Profile",
                code: errorCode(for: error),
                userInfo: [
                    NSLocalizedDescriptionKey: error.userMessage
                ]
            )
        )
    }

    // MARK: - 미디어 업로드 오류의 상세 내용을 Crashlytics에 기록
    func recordCrashlytics(_ error: MediaUploadError) {
        Crashlytics.crashlytics().record(
            error: NSError(
                domain: "Flover9.MediaUpload",
                code: errorCode(for: error),
                userInfo: [
                    NSLocalizedDescriptionKey: error.userMessage
                ]
            )
        )
    }

    // MARK: - 인증 오류에 안정적인 숫자 식별자 부여
    func errorCode(for error: AuthError) -> Int {
        switch error {
        case .cancelled: return 1000
        case .unauthenticated: return 1001
        case .invalidAppleCredential: return 1002
        case .sessionExpired: return 1003
        case .networkUnavailable: return 1004
        case .serverUnavailable: return 1005
        case .accountDeletionFailed: return 1006
        case .unknown: return 1099
        }
    }

    // MARK: - 프로필 오류에 안정적인 숫자 식별자 부여
    func errorCode(for error: ProfileError) -> Int {
        switch error {
        case .unauthenticated: return 2000
        case .notFound: return 2001
        case .invalidNickname: return 2002
        case .nicknameAlreadyExists: return 2003
        case .invalidRole: return 2004
        case .invalidProfileData: return 2005
        case .permissionDenied: return 2006
        case .networkUnavailable: return 2007
        case .serverUnavailable: return 2008
        case .unknown: return 2099
        }
    }

    // MARK: - 미디어 업로드 오류에 안정적인 숫자 식별자 부여
    func errorCode(for error: MediaUploadError) -> Int {
        switch error {
        case .unauthenticated: return 7000
        case .permissionDenied: return 7001
        case .emptyMedia: return 7002
        case .invalidFile: return 7003
        case .unsupportedMediaType: return 7004
        case .fileTooLarge: return 7005
        case .duplicatedSortOrder: return 7006
        case .uploadFailed: return 7007
        case .finalizationFailed: return 7008
        case .cleanupPending: return 7009
        case .networkUnavailable: return 7010
        case .serverUnavailable: return 7011
        case .unknown: return 7099
        }
    }
}

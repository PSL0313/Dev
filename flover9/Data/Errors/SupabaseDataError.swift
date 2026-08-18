//
//  SupabaseDataError.swift
//  flover9
//
//  Created by 박선린 on 8/11/26.
//
import Foundation
import Supabase

// MARK: - Supabase SDK 오류를 Data 계층에서 공통으로 분류한 오류
nonisolated enum SupabaseDataError: Error, Sendable, Equatable {
    case network       // 네트워크 연결 실패
    case unauthorized  // 인증 또는 RLS 권한 부족
    case notFound      // 요청한 단일 행을 찾지 못함
    case decoding      // 응답 JSON 변환 실패
    case database      // Postgres 또는 PostgREST 처리 실패
    case unknown       // 분류하지 못한 외부 오류

    static func map(_ error: Error) -> Self {
        if error is DecodingError {
            return .decoding
        }

        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet,
                 .networkConnectionLost,
                 .timedOut,
                 .cannotConnectToHost,
                 .cannotFindHost:
                return .network

            default:
                return .unknown
            }
        }

        if let postgrestError = error as? PostgrestError {
            return mapPostgrestError(postgrestError)
        }

        return .unknown
    }

    private static func mapPostgrestError(
        _ error: PostgrestError
    ) -> Self {
        switch error.code {
        case "42501", "28P01":
            return .unauthorized

        case "PGRST116":
            return .notFound // single() 조회 결과가 없거나 하나가 아닌 경우

        default:
            return .database
        }
    }
}

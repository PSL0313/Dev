//
//  SupabaseAuthRepository.swift
//  flover9
//
//  Created by 박선린 on 7/30/26.
//


import Foundation
import Supabase
import Functions

// MARK: - 애플 로그인으로 받은 토큰으로 수파베이스 로그인 및 세션조회
actor SupabaseAuthRepository: AuthRepositoryProtocol {

    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    // MARK: - Apple 계정으로 Supabase 로그인
    func signInWithApple(credential: AppleSignInCredential) async throws -> AuthSession {
        do {
            let session = try await client.auth.signInWithIdToken(
                credentials: OpenIDConnectCredentials(
                    provider: .apple,                       // Apple 인증 제공자
                    idToken: credential.identityToken,     // Apple identity token
                    nonce: credential.rawNonce             // 원본 nonce
                )
            )

            return session.toEntity()                      // Domain 세션으로 변환
        } catch {
            throw mapAuthError(error)                      // 인증 오류 매핑
        }
    }

    // MARK: - 현재 저장된 인증 세션 조회
    func fetchCurrentSession() async throws -> AuthSession? {
        do {
            let session = try await client.auth.session    // 유효한 세션 조회
            return session.toEntity()                      // Domain 세션으로 변환
        } catch Auth.AuthError.sessionMissing {
            return nil                                     // 로그인 세션 없음
        } catch {
            throw mapAuthError(error)                      // 그 외 인증 오류 매핑
        }
    }

    // MARK: - 현재 사용자 로그아웃
    func signOut() async throws {
        do {
            try await client.auth.signOut()                // Supabase 로그아웃
        } catch {
            throw mapAuthError(error)                      // 로그아웃 오류 매핑
        }
    }

    // MARK: - Apple 연결 해제와 Supabase 회원탈퇴
    func deleteAccount(authorizationCode: String) async throws {
        do {
            let requestDTO = DeleteAccountRequestDTO(
                authorizationCode: authorizationCode       // Apple 인증 코드 전달
            )

            let response: DeleteAccountResponseDTO =
                try await client.functions.invoke(
                    "delete-account",
                    options: FunctionInvokeOptions(
                        body: requestDTO                    // Function 요청 데이터
                    )
                )

            guard response.success else {
                throw AuthError.accountDeletionFailed      // 서버의 탈퇴 처리 실패
            }

            try? await client.auth.signOut(scope: .local)  // 로컬 세션 정리
        } catch {
            throw mapAuthError(error)                      // 회원탈퇴 오류 매핑
        }
    }

    
    // MARK: - 외부 인증 오류를 Domain 인증 오류로 변환
    nonisolated private func mapAuthError(_ error: Error) -> AuthError {
        if let authError = error as? AuthError {
            return authError                         // 기존 Domain 오류 유지
        }

        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet,
                 .networkConnectionLost,
                 .cannotFindHost,
                 .cannotConnectToHost,
                 .dnsLookupFailed,
                 .timedOut:
                return .networkUnavailable           // 네트워크 연결 문제

            default:
                return .serverUnavailable            // 그 외 네트워크 요청 오류
            }
        }

        if let supabaseAuthError = error as? Auth.AuthError {
            switch supabaseAuthError.errorCode {
            case .sessionNotFound,
                 .noAuthorization,
                 .userNotFound:
                return .unauthenticated              // 유효한 인증 정보가 없음

            case .sessionExpired,
                 .refreshTokenNotFound,
                 .refreshTokenAlreadyUsed:
                return .sessionExpired               // 세션을 더 이상 갱신할 수 없음

            case .badJWT,
                 .invalidJWT,
                 .badOAuthCallback,
                 .oauthProviderNotSupported,
                 .unexpectedAudience:
                return .invalidAppleCredential       // Apple 인증 정보가 유효하지 않음

            case .unexpectedFailure:
                return .serverUnavailable            // Supabase 인증 서버 오류

            default:
                return .unknown                      // 아직 분류하지 않은 인증 오류
            }
        }

        if let functionsError = error as? FunctionsError {
            switch functionsError {
            case .relayError:
                return .serverUnavailable            // Edge Function 연결 실패

            case .httpError(let code, _):
                switch code {
                case 401, 403:
                    return .unauthenticated           // Function 인증 또는 권한 실패

                case 500...599:
                    return .serverUnavailable         // Edge Function 서버 오류

                default:
                    return .accountDeletionFailed     // 회원탈퇴 요청 처리 실패
                }
            }
        }

        if error is DecodingError {
            return .serverUnavailable                 // 서버 응답 형식이 올바르지 않음
        }

        return .unknown                               // 분류하지 못한 외부 오류
    }
}

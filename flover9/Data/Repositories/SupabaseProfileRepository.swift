//
//  SupabaseProfileRepository.swift
//  flover9
//
//  Created by 박선린 on 7/31/26.
//


import Foundation
import Supabase
import Auth
import PostgREST

// MARK: - Supabase를 통해 사용자 프로필 데이터를 처리하는 Repository
actor SupabaseProfileRepository: ProfileRepositoryProtocol {
    private let client: SupabaseClient    // Supabase 요청에 사용하는 클라이언트
    
    // MARK: - Supabase 클라이언트 주입
    init(client: SupabaseClient) {
        self.client = client              // 주입받은 클라이언트 보관
    }
    
    // MARK: - 현재 로그인한 사용자의 프로필 조회
    func fetchMyProfile() async throws -> UserProfile {
        do {
            let session = try await client.auth.session
            let userID = session.user.id
            
            let profileDTO: ReadUserProfileDTO = try await client
                .from("profiles")
                .select()
                .eq("id", value: userID)
                .single()
                .execute()
                .value      // 조회 응답을 DTO로 디코딩
            
            return try profileDTO.toEntity() // DTO를 Domain Entity로 변환
        } catch let error as ProfileError {
            throw error                    // ProfileError로 변환이되면(이미 ProfileError이면) 즉시 던짐
        } catch {
            throw mapProfileError(error)   // SDK 오류를 Domain 오류로 변환
        }
    }
    
    // MARK: - 현재 로그인한 사용자의 프로필 수정
    func updateMyProfile(nickname: String?, profileImageURL: URL?) async throws -> UserProfile {
        do {
            let session = try await client.auth.session
            let userID = session.user.id             // 현재 사용자 ID 조회
            
            let updateDTO = UpdateUserProfileDTO(
                nickname: nickname,                  // 변경할 닉네임 전달
                profileImageURL: profileImageURL?
                    .absoluteString                  // URL을 문자열로 변환
            )
            
            let profileDTO: ReadUserProfileDTO = try await client
                .from("profiles")
                .update(updateDTO)                   // 허용된 프로필 열 수정
                .eq("id", value: userID)             // 현재 사용자의 행만 선택
                .select()                            // 수정된 프로필 다시 조회
                .single()                            // 단일 프로필 행 요청
                .execute()
                .value                               // 응답을 DTO로 디코딩
            
            return try profileDTO.toEntity()         // DTO를 Domain Entity로 변환
        } catch let error as ProfileError {
            throw error                              // Domain 오류 그대로 전달
        } catch {
            throw mapProfileError(error)             // SDK 오류를 Domain 오류로 변환
        }
    }
    
    
    // MARK: - 외부 오류를 프로필 Domain 오류로 변환
    nonisolated private func mapProfileError(_ error: Error ) -> ProfileError {
        if let authError = error as? Auth.AuthError {
            switch authError {
            case .sessionMissing:
                return .unauthenticated              // 인증 세션이 없음
                
            default:
                return .serverUnavailable            // 그 외 인증 오류
            }
        }
        
        if let postgrestError = error as? PostgrestError {
            switch postgrestError.code {
            case "PGRST116":
                return .notFound                     // 프로필 행이 없음
                
            case "23505":
                return .nicknameAlreadyExists        // UNIQUE 제약조건 위반 (중복 닉네임)
                
            case "42501":
                return .permissionDenied             // RLS 또는 DB 권한 거부
                
            default:
                return .serverUnavailable            // 그 외 DB 오류
            }
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
                return .serverUnavailable            // 그 외 네트워크 오류
            }
        }
        
        if error is DecodingError {
            return .invalidProfileData               // 응답 데이터 변환 실패
        }
        
        return .unknown                              // 알 수 없는 오류
    }
}

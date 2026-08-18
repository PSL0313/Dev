//
//  SupabaseMemberRemoteDataSource.swift
//  flover9
//
//  Created by 박선린 on 8/11/26.
//
import Foundation
import Supabase

// MARK: - Supabase members 테이블에서 멤버 정보를 조회하는 원격 DataSource
final class SupabaseMemberRemoteDataSource: MemberRemoteDataSourceProtocol {
    private let supabaseClient: SupabaseClient // Supabase 요청 클라이언트
    
    init(supabaseClient: SupabaseClient) {
        self.supabaseClient = supabaseClient // 주입받은 클라이언트 보관
    }
    
    // MARK: - 화면에 노출할 활성 멤버 목록 조회
    func getMembers() async throws -> [MemberDTO] {
        do {
            let members: [MemberDTO] = try await supabaseClient
                .from("members")
                .select("""
                            code,
                            display_name,
                            sort_order,
                            is_active,
                            created_at,
                            entity_type,
                            profile_image_url
                        """)
                .eq("entity_type", value: "member")
                .eq("is_active", value: true)
                .order("sort_order", ascending: true)
                .execute()
                .value
            
            return members // 표시 순서대로 정렬된 멤버 DTO 반환
            
        } catch {
            throw SupabaseDataError.map(error) // SDK 오류를 Data 오류로 변환
        }
    }
    
    // MARK: - 멤버 코드에 해당하는 활성 멤버 한 명 조회
    func getMember(code: MemberCode) async throws -> MemberDTO {
        do {
            let member: MemberDTO = try await supabaseClient
                .from("members")
                .select("""
                            code,
                            display_name,
                            sort_order,
                            is_active,
                            created_at,
                            entity_type,
                            profile_image_url
                        """)
                .eq("code", value: code.rawValue)
                .eq("entity_type", value: "member")
                .eq("is_active", value: true)
                .single()
                .execute()
                .value
            return member // 단일 멤버 DTO 반환
        } catch {
            throw SupabaseDataError.map(error) // SDK 오류를 Data 오류로 변환
        }
    }
}

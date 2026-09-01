//
//  DeleteAccountResponseDTO.swift
//  flover9
//
//  Created by 박선린 on 7/30/26.
//


// MARK: - 회원탈퇴 Edge Function 응답 정보
nonisolated struct DeleteAccountResponseDTO: Decodable, Sendable {
    let success: Bool             // 탈퇴 요청 접수 또는 즉시 삭제 성공 여부
    let deletionPending: Bool     // Supabase 계정 삭제 자동 재시도 대기 여부
    let message: String           // 서버 처리 결과 메시지
}

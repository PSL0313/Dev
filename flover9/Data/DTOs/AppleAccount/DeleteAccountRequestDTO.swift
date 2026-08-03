//
//  DeleteAccountRequestDTO.swift
//  flover9
//
//  Created by 박선린 on 7/30/26.
//

// MARK: - 회원탈퇴 Edge Function 요청 정보
nonisolated struct DeleteAccountRequestDTO: Encodable, Sendable {
    let authorizationCode: String    // Apple 재인증 코드
}

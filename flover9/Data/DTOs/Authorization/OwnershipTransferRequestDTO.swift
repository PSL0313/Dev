//
//  OwnershipTransferRequestDTO.swift
//  flover9
//
//  Created by 박선린 on 9/29/26.
//

import Foundation

// 어드민 이전 전용 요청입니다. 서버가 현재 JWT의 어드민 여부를 다시 확인합니다.
nonisolated struct OwnershipTransferRequestDTO: Encodable, Sendable {
    let action = "transferOwnership" // 어드민 이전 작업
    let userID: UUID // 새 어드민가 될 회원 ID
    let reason: String // 이전 사유
}

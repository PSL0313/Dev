//
//  DeleteMediaResponseDTO.swift
//  flover9
//
//  Created by 박선린 on 8/27/26.
//


// MARK: - 미디어 삭제 응답
nonisolated struct DeleteMediaResponseDTO: Decodable, Sendable {
    let deleted: Bool
    let cleanupPending: Bool
}

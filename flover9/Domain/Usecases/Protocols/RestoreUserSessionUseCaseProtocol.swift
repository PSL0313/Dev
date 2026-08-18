//
//  RestoreUserSessionUseCaseProtocol.swift
//  flover9
//
//  Created by 박선린 on 7/31/26.
//


// MARK: - 저장된 Supabase 세션으로 기존 사용자 정보를 복원하는 기능
protocol RestoreUserSessionUseCaseProtocol: Sendable {
    func execute() async throws -> Bool
}
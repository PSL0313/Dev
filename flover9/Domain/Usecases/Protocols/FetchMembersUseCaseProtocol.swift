//
//  FetchMembersUseCaseProtocol.swift
//  flover9
//
//  Created by 박선린 on 8/11/26.
//

// MARK: - 화면에서 사용할 멤버 목록 조회 기능 규약
protocol FetchMembersUseCaseProtocol {
    func execute() async throws -> [MemberEntity] // 활성 멤버 목록 반환
}

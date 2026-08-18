//
//  MemberRepositoryProtocol.swift
//  flover9
//
//  Created by 박선린 on 8/11/26.
//

// MARK: - 멤버 데이터 접근을 Domain 계층에 제공하는 저장소 규약
protocol MemberRepositoryProtocol {
    func fetchMembers() async throws -> [MemberEntity]             // 활성 멤버 목록 조회
    func fetchMember(code: MemberCode) async throws -> MemberEntity // 특정 멤버 조회
}

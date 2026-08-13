//
//  MemberRemoteDataSourceProtocol.swift
//  flover9
//
//  Created by 박선린 on 8/11/26.
//

// MARK: - 원격 멤버 데이터 조회 기능 규약
protocol MemberRemoteDataSourceProtocol {
    func getMembers() async throws -> [MemberDTO] // 활성 멤버 목록 조회
    
    func getMember(code: MemberCode) async throws -> MemberDTO // 특정 활성 멤버 조회
}

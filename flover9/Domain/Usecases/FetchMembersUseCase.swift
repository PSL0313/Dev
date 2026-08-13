//
//  FetchMembersUseCase.swift
//  flover9
//
//  Created by 박선린 on 8/11/26.
//

// MARK: - 활성 멤버 목록을 조회하는 UseCase
final class FetchMembersUseCase: FetchMembersUseCaseProtocol {
    private let memberRepository: MemberRepositoryProtocol // 멤버 저장소 규약

    init(memberRepository: MemberRepositoryProtocol) {
        self.memberRepository = memberRepository // 주입받은 저장소 보관
    }

    func execute() async throws -> [MemberEntity] {
        try await memberRepository.fetchMembers() // 저장소를 통해 멤버 목록 조회
    }
}

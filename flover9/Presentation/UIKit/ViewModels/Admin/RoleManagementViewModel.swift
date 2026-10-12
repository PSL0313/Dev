//
//  RoleManagementViewModel.swift
//  flover9
//
//  Created by 박선린 on 9/29/26.
//

import Foundation

// 회원 검색·페이지 조회와 역할 변경 상태를 관리하고 변경 후 최신 권한을 다시 읽습니다.
@MainActor final class RoleManagementViewModel {
    nonisolated deinit {}
    private let useCase: AuthorizationUseCaseProtocol
    private var task: Task<Void, Never>?
    private var query = ""
    private(set) var members: [RoleMember] = [] // 현재 검색 결과
    private(set) var access: UserAuthorization? // 마지막으로 확인한 실행자 권한
    private(set) var isLoading = false // 목록 또는 권한 조회 중
    private(set) var isSaving = false // 역할 변경 처리 중; 중복 실행 차단
    private(set) var hasMore = false // 다음 회원 페이지 존재 여부
    private(set) var message: String? // 목록 상태와 조회 오류
    var onChange: (() -> Void)?
    var onMessage: ((String, String) -> Void)?
    init(useCase: AuthorizationUseCaseProtocol) { self.useCase = useCase }

    func load(query: String? = nil, more: Bool = false) {
        guard !isSaving, !more || (!isLoading && hasMore) else { return }
        if let query { self.query = query }
        task?.cancel()
        if !more { members = []; hasMore = false }
        let offset = more ? members.count : 0
        let search = self.query
        access = nil
        isLoading = true
        message = nil
        onChange?()
        task = Task { [weak self] in
            guard let self else { return }
            do {
                let current = try await useCase.current()
                guard current.allows(.rolesRead) else { throw AuthorizationError.denied }
                let page = try await useCase.members(query: search, offset: offset)
                try Task.checkCancellation()
                access = current
                members += page
                hasMore = page.count == 50
                message = members.isEmpty ? "검색된 회원이 없어요." : nil
            } catch {
                guard !Task.isCancelled else { return }
                members = []
                hasMore = false
                message = error.localizedDescription
            }
            isLoading = false
            onChange?()
        }
    }
    func change(_ member: RoleMember, to role: UserRole?, reason: String) {
        mutate { try await self.useCase.setRole(member: member, role: role, reason: reason) }
    }
    func transfer(to member: RoleMember, reason: String) {
        mutate { try await self.useCase.transfer(to: member, reason: reason) }
    }
    private func mutate(_ operation: @escaping () async throws -> Void) {
        guard !isSaving, !isLoading, access != nil else { return }
        isSaving = true
        onChange?()
        task = Task { [weak self] in
            guard let self else { return }
            var outcome = "회원의 역할을 변경했어요."
            var title = "변경 완료"
            do { try await operation() }
            catch { title = "변경 결과 확인"; outcome = error.localizedDescription }
            isSaving = false
            load()
            onMessage?(title, outcome)
        }
    }
}

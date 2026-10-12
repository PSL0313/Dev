//
//  AdminDashboardViewModel.swift
//  flover9
//
//  Created by 박선린 on 9/24/26.
//

import Foundation

@MainActor
final class AdminDashboardViewModel {
    enum State {
        case checking
        case ready(ManagementIdentity)
        case unavailable(String)
    }

    enum Route {
        case manage(AdminCategory)
    }

    var onState: ((State) -> Void)?
    var onRoute: ((Route) -> Void)?

    private let useCase: AdminUseCaseProtocol
    private var task: Task<Void, Never>?
    private var access: UserAuthorization?

    init(useCase: AdminUseCaseProtocol) {
        self.useCase = useCase
    }

    // MARK: - 탭에 다시 진입할 때 캐시된 권한 대신 최신 권한 확인
    func checkAccess() {
        task?.cancel()
        access = nil
        onState?(.checking)
        task = Task { [weak self] in
            guard let self else { return }
            do {
                let profile = try await useCase.authorize()
                guard !Task.isCancelled else { return }
                access = profile.authorization
                onState?(.ready(profile))
            } catch {
                guard !Task.isCancelled else { return }
                let message = (error as? AdminError)?.userMessage ?? (error as? AuthorizationError)?.errorDescription ?? "권한을 확인하지 못했어요. 다시 시도해 주세요."
                onState?(.unavailable(message))
            }
        }
    }

    func open(_ category: AdminCategory) {
        guard access?.allows(category == .feeds ? .feedManageAny : .scheduleManage) == true else { return }
        onRoute?(.manage(category))
    }
}

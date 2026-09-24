import Foundation

@MainActor
final class AdminDashboardViewModel {
    enum State {
        case checking
        case ready(UserProfile)
        case unavailable(String)
    }

    enum Route {
        case manage(AdminCategory)
    }

    var onState: ((State) -> Void)?
    var onRoute: ((Route) -> Void)?

    private let useCase: AdminUseCaseProtocol
    private var task: Task<Void, Never>?
    private var isAuthorized = false

    init(useCase: AdminUseCaseProtocol) {
        self.useCase = useCase
    }

    // MARK: - 탭에 다시 진입할 때 캐시된 권한 대신 최신 권한 확인
    func checkAccess() {
        task?.cancel()
        isAuthorized = false
        onState?(.checking)
        task = Task { [weak self] in
            guard let self else { return }
            do {
                let profile = try await useCase.authorize()
                guard !Task.isCancelled else { return }
                isAuthorized = true
                onState?(.ready(profile))
            } catch {
                guard !Task.isCancelled else { return }
                let message = (error as? AdminError)?.userMessage ?? "권한을 확인하지 못했어요. 다시 시도해 주세요."
                onState?(.unavailable(message))
            }
        }
    }

    func open(_ category: AdminCategory) {
        guard isAuthorized else { return }
        onRoute?(.manage(category))
    }
}

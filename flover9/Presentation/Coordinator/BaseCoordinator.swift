import UIKit

/// UIKit Coordinator들이 공통으로 사용하는 화면 전환 기반과
/// 자식 Coordinator의 생명주기 관리만 담당합니다.
class BaseCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []

    func start() {
        assertionFailure("하위 Coordinator에서 start()를 구현해야 합니다.")
    }

    func addChild(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }

    func removeChild(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }

    func removeAllChildren() {
        childCoordinators.removeAll()
    }
}

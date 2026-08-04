import SwiftUI
import UIKit

/// 앱의 최상위 화면 흐름을 소유합니다.
final class AppCoordinator: BaseCoordinator {
    private let window: UIWindow
    private let container: AppDIContainer
    private let rootContainer = RootContainerViewController()
    
    var onRequestAppReset: (() -> Void)?           // SceneDelegate에 재시작 요청
    
    init(window: UIWindow, container: AppDIContainer) {
        self.window = window
        self.container = container
    }

    override func start() {
        window.rootViewController = rootContainer
        window.makeKeyAndVisible()

        showLaunchFlow()
    }
}

private extension AppCoordinator {
    // 초기화면 시작(사용자 로그인 확인 및 플로우 결정
    private func showLaunchFlow() {
        // 런치 코디네이터 생성
        let coordinator = LaunchCoordinator(
            container: container,
            rootContainer: rootContainer
        )
        
        // 메인플로우로 넘어갈 준비가 될 때 실행할 클로저
        coordinator.onReadyForMain = { [weak self, weak coordinator] in
            guard let self else { return }

            self.showMainFlow()

            if let coordinator {
                self.removeChild(coordinator)
            }
        }
        
        // 자식 코디네이터 목록 추가
        addChild(coordinator)
        
        // 코디네이터 실행
        coordinator.start()
    }
    
    // 사용자가 확인되면 메인 플로우 시작
    private func showMainFlow() {
        // 메인코디네이터 생성
        let coordinator = MainCoordinator(
            container: container
        )
        coordinator.onRequestAppReset = { [weak self] in
            self?.onRequestAppReset?()                           // SceneDelegate에 전체 재시작 요청
        }
        
        // 자식코디네이터 배열에 추가
        addChild(coordinator)
        
        //코디네이터 실행
        coordinator.start()

        // 런치뷰 뒤에 숨겨서 추가
        rootContainer.installMainBehindLaunch(
            coordinator.tabBarController
        )

        // 런치뷰를 내리고 삭제하고 메인뷰를 화면에 보이기
        rootContainer.dismissLaunch()
    }
}

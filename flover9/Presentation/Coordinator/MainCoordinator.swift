//
//  MainCoordinator.swift
//  flover9
//
//  Created by 박선린 on 7/27/26.
//

import UIKit

final class MainCoordinator: BaseCoordinator {
    let tabBarController = UITabBarController()
    private let container: AppDIContainer
    
    var onRequestAppReset: (() -> Void)?            // AppCoordinator에 재시작 요청
    var onReadyForShowHome: (() -> Void)?           // 초기 데이터 fetch 완료
    
    init(container: AppDIContainer) {
        self.container = container
    }

    override func start() {
        // 하위(자식)코디네이터 생성
        let homeCoordinator = makeHomeCoordinator()
        let profileCoordinator = makeProfileCoordinator()
        let adminCoordinator = makeAdminCoordinator()
        
        
        // 하위(자식) 코디네이터 등록
        addChild(homeCoordinator)
        addChild(profileCoordinator)
        addChild(adminCoordinator)
        
        // 하위 코디네이터 시작
        homeCoordinator.start()
        profileCoordinator.start()
        adminCoordinator.start()
        
        // test
        let signOutTest = makeHomeCoordinator()
        addChild(signOutTest)
        signOutTest.start1()
        
        // 탭바에 연결할 화면들
        tabBarController.viewControllers = [
            homeCoordinator.navigationController,
            signOutTest.navigationController,
            profileCoordinator.navigationController,
            adminCoordinator.navigationController        // 임시 네 번째 관리자 탭
        ]
        
        // 탭바에 연결된 화면들 중 처음에 보여질 탭
        tabBarController.selectedIndex = 0
        
        tabBarController.tabBar.tintColor = .label
    }
}

private extension MainCoordinator {
    // MARK: - 진입 위치를 변경할 때 이 탭 연결만 제거하면 된다.
    func makeAdminCoordinator() -> AdminCoordinator {
        let navigationController = UINavigationController()
        navigationController.tabBarItem = UITabBarItem(
            title: "관리자",
            image: UIImage(systemName: "slider.horizontal.3"),
            selectedImage: UIImage(systemName: "slider.horizontal.3")
        )
        return AdminCoordinator(navigationController: navigationController, container: container)
    }

    func makeHomeCoordinator() -> HomeCoordinator {
        let navigationController = UINavigationController()
        navigationController.tabBarItem = UITabBarItem(
            title: "홈",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )

        let coordinator = HomeCoordinator(
            navigationController: navigationController,
            container: container
        )
        coordinator.onRequestAppReset = { [weak self] in
            self?.onRequestAppReset?()                           // 하위 요청을 상위로 전달
        }
        
        coordinator.onReadyForShowHome = { [weak self] in
            self?.onReadyForShowHome?()                 
        }
        return coordinator
    }

    func makeProfileCoordinator() -> ProfileCoordinator {
        let navigationController = UINavigationController()
        navigationController.tabBarItem = UITabBarItem(
            title: "프로필",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )
        let coordinator = ProfileCoordinator(
            navigationController: navigationController,
            container: container
        )
        
        coordinator.onRequestAppReset = { [weak self] in
            self?.onRequestAppReset?()                           // 하위 요청을 상위로 전달
        }
        
        return coordinator
    }
}

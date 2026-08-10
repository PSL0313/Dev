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
    
    var onRequestAppReset: (() -> Void)?                         // AppCoordinator에 재시작 요청
    
    init(container: AppDIContainer) {
        self.container = container
    }

    override func start() {
        // 하위(자식)코디네이터 생성
        let homeCoordinator = makeHomeCoordinator()
        let profileCoordinator = makeProfileCoordinator()
        
        // 하위(자식) 코디네이터 등록
        addChild(homeCoordinator)
        addChild(profileCoordinator)
        
        // 하위 코디네이터 시작
        homeCoordinator.start()
        profileCoordinator.start()
        
        // 탭바에 연결할 화면들
        tabBarController.viewControllers = [
            homeCoordinator.navigationController,
            profileCoordinator.navigationController
        ]
        
        // 탭바에 연결된 화면들 중 처음에 보여질 탭
        tabBarController.selectedIndex = 0
    }
}

private extension MainCoordinator {
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
        return coordinator
    }

    func makeProfileCoordinator() -> ProfileCoordinator {
        let navigationController = UINavigationController()
        navigationController.tabBarItem = UITabBarItem(
            title: "프로필",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )

        return ProfileCoordinator(
            navigationController: navigationController,
            container: container
        )
    }
}

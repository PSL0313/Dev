//
//  ProfileCoordinator.swift
//  flover9
//
//  Created by 박선린 on 7/27/26.
//

import UIKit
import SwiftUI

final class ProfileCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    private let container: AppDIContainer
    
    init(navigationController: UINavigationController, container: AppDIContainer) {
        self.navigationController = navigationController
        self.container = container
    }
    
    func start() {
        let viewController = UIHostingController(
            rootView: FeedGridTestView(repository:container.feedRepository)
        )
        viewController.view.backgroundColor = .systemBlue
        viewController.title = "프로필"

        navigationController.setViewControllers(
            [viewController],
            animated: false
        )
    }
    
    
}

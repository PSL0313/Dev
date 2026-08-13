//
//  ProfileCoordinator.swift
//  flover9
//
//  Created by 박선린 on 7/27/26.
//

import UIKit
import SwiftUI

final class ProfileCoordinator: BaseCoordinator {
    var navigationController: UINavigationController
    private let container: AppDIContainer
    
    init(navigationController: UINavigationController, container: AppDIContainer) {
        self.navigationController = navigationController
        self.container = container
    }
    
    override func start() {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .systemBlue
        viewController.title = "프로필"

        navigationController.setViewControllers(
            [viewController],
            animated: false
        )
    }
    
    
}

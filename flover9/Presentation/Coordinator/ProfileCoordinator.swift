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
    var onRequestAppReset: (() -> Void)?               // 앱 전체 재시작 요청
    
    init(navigationController: UINavigationController, container: AppDIContainer) {
        self.navigationController = navigationController
        self.container = container
    }
    
    override func start() {
        let viewController = MyViewController(viewModel: MyViewModel())
        

        navigationController.setViewControllers(
            [viewController],
            animated: false
        )
    }
    
    
}

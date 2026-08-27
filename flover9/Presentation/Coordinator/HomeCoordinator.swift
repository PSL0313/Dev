//
//  HomeCoordinator.swift
//  flover9
//
//  Created by 박선린 on 7/27/26.
//

import UIKit

final class HomeCoordinator: BaseCoordinator {
    
    var navigationController: UINavigationController
    var onRequestAppReset: (() -> Void)?               // 앱 전체 재시작 요청
    var onReadyForShowHome: (() -> Void)?              // 초기 데이터 fetch 완료
    
    private let container: AppDIContainer              // 테스트 화면 의존성 생성 객체
    
    init(
        navigationController: UINavigationController,
        container: AppDIContainer
    ) {
        self.navigationController = navigationController
        self.container = container
    }
    
    override func start() {
        let viewModel = container.getHomeViewModel()
        viewModel.onRoute = { [weak self] route in
            switch route {
            case .fetchedHomeData:
                self?.onReadyForShowHome?()
            case .failed(let msg):
                self?.showAlert(title: "에러", message: msg)
            case .moveToMemberProfileView(let member):
                self?.showMemberProfileView(member: member)
            }
        }
        
        let viewController = HomeViewController(viewModel: viewModel)

        navigationController.setViewControllers(
            [viewController],
            animated: false
        )
        viewModel.action(.start)
    }
    
    func start1() {
        let viewModel = container.getTestHomeViewModel()
        viewModel.onRoute = { [weak self] route in
            switch route {
            case .resetApp:
                self?.onRequestAppReset?()                       // SceneDelegate까지 재시작 전달
            case .failed(let title, let message):
                self?.showAlert(
                    title: title,
                    message: message
                )
            }
        }
        
        let viewController = TestHomeViewController(
            viewModel: viewModel,
            appleSignInService: container.makeAppleSignInService()
        )

        navigationController.setViewControllers(
            [viewController],
            animated: false
        )
    }
    
    // MARK: - 테스트 요청 오류 Alert 표시
    private func showAlert(
        title: String,
        message: String
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: "확인",
                style: .default
            )
        )
        
        navigationController.present(alert, animated: true)
    }
    
    private func showMemberProfileView(member: MemberEntity) {
        let vc = MemberProfileViewViewController(viewModel: container.getMemberProfileViewModel(member))
        self.navigationController.pushViewController(vc, animated: true)
    }
}

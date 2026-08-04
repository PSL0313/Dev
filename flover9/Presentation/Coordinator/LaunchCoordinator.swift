//
//  LaunchCoordinator.swift
//  flover9
//
//  Created by 박선린 on 7/27/26.
//
import UIKit
import SwiftUI

final class LaunchCoordinator: BaseCoordinator {
    // MARK: - Property
    private let container: AppDIContainer
    private let rootContainer: RootContainerViewController
    
    // MARK: - Closure
    var onReadyForMain: (() -> Void)?
    
    // MARK: - Init
    init(
        container: AppDIContainer,
        rootContainer: RootContainerViewController
    ) {
        self.container = container
        self.rootContainer = rootContainer
        super.init()
    }
    
    override func start() {
        showLaunch()
    }
    
    private func showLaunch() {
        // 뷰모델 생성
        let viewModel = container.getLaunchViewModel()

        // 클로저 주입
        viewModel.onRoute = { [weak self] route in
            guard let self else { return }
            switch route {
            case .onLoginRequired:
                showLogin()
            case .main:
                onReadyForMain?()
            case .failed(let title, let message):
                showAlert(
                    title: title,
                    message: message
                )
            case .updateRequired:
                openAppStore()
            case .maintenance(let msg):
                showMaintenance(message: msg)
            }
        }
        // 뷰컨 생성 및 뷰모델 주입
        let viewController = LaunchViewController(
            viewModel: viewModel
        )
        
        // 루트컨테이너뷰컨트롤러에서 런치뷰 실행
        rootContainer.showLaunch(viewController)
    }
    
    private func showLogin() {
        // 로고를 위로 옮기고 로그인 화면을 올리는 작업
        let viewModel = container.getSignInViewModel()
        viewModel.onRoute = { [weak self] route in
            guard let self else { return }
            switch route {
            case .authenticationCompleted:
                rootContainer.hideSignIn()                      // 인증 완료 후 로그인 화면 제거 및 세션 재확인
            case .failed(let title, let message):
                showAlert(
                    title: title,
                    message: message
                )                                               // 실제 발생한 오류 안내
            }
        }
        let vc = SignInViewController(viewModel: viewModel, appleSignInService: container.makeAppleSignInService())
        
        // 루트컨테이너에게 signInViewController 주입
        self.rootContainer.showSignIn(signInViewController: vc)
        
    }
    
    // MARK: - 확인 버튼만 있는 안내 Alert 표시
    private func showAlert(
        title: String,
        message: String
    ) {
        let alert = UIAlertController(
            title: title,                              // Alert 제목
            message: message,                          // 안내 내용
            preferredStyle: .alert                     // 화면 중앙 Alert 형태
        )

        let confirmAction = UIAlertAction(
            title: "확인",                             // 버튼 제목
            style: .default
        )

        alert.addAction(confirmAction)                  // 확인 버튼 추가
        rootContainer.present(alert, animated: true)                  // 현재 ViewController가 표시
    }
}

private extension LaunchCoordinator {
    // MARK: - Flover9 App Store 페이지 열기
    func openAppStore() {

        let alert = UIAlertController(
            title: "업데이트",                              // Alert 제목
            message: "업데이트가 필요합니다. 확인을 누르면 Appstore로 이동합니다.",                          // 안내 내용
            preferredStyle: .alert                     // 화면 중앙 Alert 형태
        )

        let confirmAction = UIAlertAction(
            title: "확인",                             // 버튼 제목
            style: .default
        ) { _ in
            guard let url = URL(
                string: ""  // 수정필요
            ) else {
                return
            }

            UIApplication.shared.open(url)
        }

        alert.addAction(confirmAction)                  // 확인 버튼 추가
        rootContainer.present(alert, animated: true)                  // 현재 ViewController가 표시
    }
    
    // MARK: - 점검 중 화면
    
    func showMaintenance(message msg: String) {
        let hostingController = UIHostingController(
            rootView: MaintenanceView(message: msg)
        )

        hostingController.modalPresentationStyle = .fullScreen

        rootContainer.present(
            hostingController,
            animated: true
        )
    }
    
}

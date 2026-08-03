//
//  TestHomeViewController.swift
//  flover9
//

import AuthenticationServices
import UIKit

// MARK: - 로그아웃과 회원탈퇴 동작을 확인하기 위한 테스트 홈 화면
@MainActor
final class TestHomeViewController: UIViewController {
    
    private let viewModel: TestHomeViewModel                     // 테스트 화면 상태 처리 객체
    private let appleSignInService: AppleSignInService           // 회원탈퇴용 Apple 재인증 객체
    
    private lazy var signOutButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "로그아웃"                         // 버튼 표시 문구
        configuration.baseBackgroundColor = .systemBlue          // 로그아웃 버튼 색상
        
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false // Auto Layout 사용
        button.addTarget(
            self,
            action: #selector(signOutButtonTapped),
            for: .touchUpInside
        )
        return button
    }()
    
    private lazy var deleteAccountButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "회원탈퇴"                         // 버튼 표시 문구
        configuration.baseBackgroundColor = .systemRed           // 파괴적 작업 강조
        
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false // Auto Layout 사용
        button.addTarget(
            self,
            action: #selector(deleteAccountButtonTapped),
            for: .touchUpInside
        )
        return button
    }()
    
    // MARK: - 테스트 화면 의존성 주입
    init(
        viewModel: TestHomeViewModel,
        appleSignInService: AppleSignInService
    ) {
        self.viewModel = viewModel                               // ViewModel 보관
        self.appleSignInService = appleSignInService             // Apple 인증 서비스 보관
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 화면 최초 구성
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()                                              // 버튼 배치
        bindViewModel()                                          // 상태 변화 연결
    }
    
    // MARK: - 테스트 버튼 화면 배치
    private func setLayout() {
        title = "홈"
        view.backgroundColor = .systemBackground
        
        let stackView = UIStackView(
            arrangedSubviews: [
                signOutButton,
                deleteAccountButton
            ]
        )
        stackView.axis = .vertical                               // 버튼을 위아래로 배치
        stackView.spacing = 16                                   // 버튼 사이 간격
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),
            stackView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 40
            ),
            stackView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -40
            ),
            signOutButton.heightAnchor.constraint(
                equalToConstant: 52
            ),
            deleteAccountButton.heightAnchor.constraint(
                equalToConstant: 52
            )
        ])
    }
    
    // MARK: - ViewModel 상태에 맞춰 버튼 활성 상태 변경
    private func bindViewModel() {
        viewModel.onStateChanged = { [weak self] state in
            guard let self else { return }
            
            switch state {
            case .idle:
                signOutButton.isEnabled = true                  // 사용자 입력 허용
                deleteAccountButton.isEnabled = true            // 사용자 입력 허용
            case .loading:
                signOutButton.isEnabled = false                 // 중복 요청 차단
                deleteAccountButton.isEnabled = false           // 중복 요청 차단
            }
        }
    }
    
    // MARK: - 로그아웃 버튼 동작
    @objc
    private func signOutButtonTapped() {
        viewModel.action(input: .signOutTapped)                  // ViewModel에 로그아웃 요청
    }
    
    // MARK: - 회원탈퇴 확인 Alert 표시
    @objc
    private func deleteAccountButtonTapped() {
        let alert = UIAlertController(
            title: "회원탈퇴",
            message: "계정을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.",
            preferredStyle: .alert
        )
        
        alert.addAction(
            UIAlertAction(
                title: "취소",
                style: .cancel
            )
        )
        alert.addAction(
            UIAlertAction(
                title: "탈퇴",
                style: .destructive,
                handler: { [weak self] _ in
                    self?.requestAppleAuthorization()            // 확인 후 Apple 재인증 시작
                }
            )
        )
        
        present(alert, animated: true)
    }
    
    // MARK: - 회원탈퇴에 필요한 최신 Apple 인증 코드 요청
    private func requestAppleAuthorization() {
        appleSignInService.startAppleSignIn(
            viewController: self
        ) { [weak self] result in
            self?.viewModel.action(
                input: .deleteAccountAuthorizationCompleted(result)
            )
        }
    }
}

// MARK: - Apple 인증 화면을 표시할 Window를 제공
extension TestHomeViewController:
    ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(
        for controller: ASAuthorizationController
    ) -> ASPresentationAnchor {
        view.window!                                             // 현재 테스트 화면의 Window 사용
    }
}

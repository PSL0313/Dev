//
//  SignInViewController.swift
//  flover9
//
//  Created by 박선린 on 7/27/26.
//

import UIKit
import AuthenticationServices

@MainActor
final class SignInViewController: UIViewController {
    // MARK: - ViewModel & 기타 관리 객체

    // 뷰모델
    private let viewModel: SignInViewModel
    
    // 애플 로그인 지원 객체
    private let appleSignInService: AppleSignInService
    
    // MARK: - Properties
    
    // MARK: - Views
    private lazy var appleLoginButton: ASAuthorizationAppleIDButton = {
        let appleLoginButton = ASAuthorizationAppleIDButton(type: .signIn, style: .whiteOutline)
        appleLoginButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        appleLoginButton.cornerRadius = 14
        appleLoginButton.translatesAutoresizingMaskIntoConstraints = false
        return appleLoginButton
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Didot-Bold", size: 42)
        label.textColor = .white
        label.numberOfLines = 1
        label.textAlignment = .center
        label.text = "flover_9"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let miniLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .lightGray
        label.numberOfLines = 1
        label.textAlignment = .center
        label.text = "좋아하는 순간을 한곳에"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let privacyPolicyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .light)
        label.textColor = .gray
        label.numberOfLines = 1
        label.textAlignment = .center
        label.text = "계속하려면 이용약관 및 개인정보 처리방침에 동의해야 합니다."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    init(viewModel: SignInViewModel, appleSignInService: AppleSignInService) {
        self.viewModel = viewModel
        self.appleSignInService = appleSignInService
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppleLoginButton()
    }
    

    private func setupAppleLoginButton() {
        
        // 버튼을 화면에 추가
        self.view.addSubview(titleLabel)
        self.view.addSubview(miniLabel)
        self.view.addSubview(appleLoginButton)
        self.view.addSubview(lineView)
        self.view.addSubview(privacyPolicyLabel)

        // 오토레이아웃 설정
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            
            miniLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            miniLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
         
            privacyPolicyLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            privacyPolicyLabel.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20),

            lineView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 1),
            lineView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            lineView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            lineView.bottomAnchor.constraint(equalTo: privacyPolicyLabel.topAnchor, constant: -10),
            
            appleLoginButton.heightAnchor.constraint(equalToConstant: 50),
            appleLoginButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            appleLoginButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 40),
            appleLoginButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -40),
        ])
        
        // 애플로그인 버튼 하단 제약의 우선순위를 낮게 설정
        let appleLoginButtonConstraint = appleLoginButton.bottomAnchor.constraint(equalTo: lineView.topAnchor, constant: -40)
        appleLoginButtonConstraint.priority = .fittingSizeLevel
        appleLoginButtonConstraint.isActive = true
    }
}

extension SignInViewController: ASAuthorizationControllerPresentationContextProviding {
    
    @objc
    private func handleAuthorizationAppleIDButtonPress() {
        guard view.window != nil else { return }         // 표시할 Window가 없으면 인증 시작 불가
        appleLoginButton.isEnabled = false               // 인증 요청 중 중복 탭 방지

        appleSignInService.startAppleSignIn(viewController: self) { [weak self] result in
            guard let self else { return }
            appleLoginButton.isEnabled = true            // 인증 결과 수신 후 버튼 복원
            viewModel.action(input: .appleSignInCompleted(result))
        }
    }
    
    // 애플로그인 뷰를 뛰울 window
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let window = view.window else {
            assertionFailure("Apple 로그인 화면을 표시할 Window가 없습니다.")
            return ASPresentationAnchor()
        }
        return window
    }
    
}

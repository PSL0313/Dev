//
//  LaunchViewController.swift
//  flover9
//
//  Created by 박선린 on 7/27/26.
//

import UIKit

@MainActor
class LaunchViewController: UIViewController {
    
    // 앱 로고
    let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "f9Logo")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - 화면 상태별 Constraint
    private var logoInitialConstraints: [NSLayoutConstraint] = []
    private var logoSignInConstraints: [NSLayoutConstraint] = []
    private var signInConstraints: [NSLayoutConstraint] = []
    
    // MARK: - Property
    private let viewModel: LaunchViewModel
    private weak var signInViewController: SignInViewController?
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        bindViewModel()
        
    }
    
    // MARK: - deinit
    deinit {
        print("LaunchViewController deinit")
    }
    
    // MARK: - init
    init(viewModel: LaunchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - required init
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - setLayout - 시작 레이아웃
    private func setLayout() {
        self.view.backgroundColor = .black
        view.addSubview(logoImageView)
        
        logoInitialConstraints = [
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ]
        
        logoSignInConstraints = [
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 50
            ),
            logoImageView.heightAnchor.constraint(equalToConstant: 250),
            logoImageView.widthAnchor.constraint(equalToConstant: 250)
        ]
        
        NSLayoutConstraint.activate(logoInitialConstraints) // 초기 중앙 배치 적용
        view.layoutIfNeeded()
    }
    
    private func bindViewModel() {
        self.viewModel.onStateChanged = { [weak self] state in
            self?.render(state)
        }
        self.viewModel.action(input: .startApp)
    }
    
    private func render(_ state: LaunchViewModel.State) {
        switch state {
        case .loading:
            startLogoLoadingAnimation()
        case .reLoding:
            hideLSignIn()
            
        case .loginRequired:    // 로그인 필요
            stopLogoLoadingAnimation()
            
        case .initialDataLoaded:    // 초기 데이터 로드
            stopLogoLoadingAnimation()
            
        case .updateRequired:         // 앱 업데이트 필요
            hideLSignIn(shouldRestartLaunchProcess: false)
            startLogoLoadingAnimation()
        }
    }
    
    // MARK: - 로그인 화면을 하위뷰컨으로 등록하고 로그인화면의 SuperView를 화면에 배치
    func showSignIn(signInViewController: SignInViewController) {
        guard self.signInViewController == nil else {
            return                                              // 로그인 화면 중복 추가 방지
        }
        
        stopLogoLoadingAnimation()
        self.signInViewController = signInViewController
        
        // 1. SignInViewController를 자식 ViewController로 등록
        addChild(signInViewController)
        
        // 2. SignInViewController의 루트 View를 가져옴
        let signInView = signInViewController.view!
        
        signInView.translatesAutoresizingMaskIntoConstraints = false
        
        // 3. LaunchViewController의 View에 추가
        view.addSubview(signInView)
        
        // 4. SignIn 화면 위치 지정
        signInConstraints = [
            signInView.topAnchor.constraint(
                equalTo: logoImageView.bottomAnchor,
                constant: 30
            ),
            signInView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            signInView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            signInView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            )
        ]
        NSLayoutConstraint.activate(signInConstraints)
        
        // 5. 자식 ViewController 추가 완료 알림
        signInViewController.didMove(toParent: self)
        
        // 6. 초기 세팅된 뷰의 화면에 반영(아래에 숨긴 상태)
        self.view.layoutIfNeeded()
        
        // 7. 제약 변경
        NSLayoutConstraint.deactivate(logoInitialConstraints)   // 초기 중앙 제약 해제
        NSLayoutConstraint.activate(logoSignInConstraints)      // 로그인용 상단 제약 적용
        
        // 8. 변경한 제약을 애니메이션을 통해 화면에 반영
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - 로그인 화면을 제거하고 Launch 초기 화면으로 복원
    func hideLSignIn(shouldRestartLaunchProcess: Bool = true) {
        guard let signInViewController else {
            if shouldRestartLaunchProcess {
                viewModel.action(input: .startApp)
            }
            return                                              // 제거할 로그인 화면이 없음
        }
        
        signInViewController.willMove(toParent: nil)             // 자식 제거 예정 알림
        
        /// 여기서는 signInConstraints 제약 해제 금지 -> 제약이 없어지면서 순간 비정상적으로 배치된다.
        NSLayoutConstraint.deactivate(logoSignInConstraints)      // 로그인용 로고 제약 해제
        NSLayoutConstraint.activate(logoInitialConstraints)       // 초기 중앙 제약 복원
        
        UIView.animate(
            withDuration: 0.5,
            animations: {
                signInViewController.view.alpha = 0              // 로그인 화면 숨김
                self.view.layoutIfNeeded()                        // 로고 중앙 이동
            },
            completion: { [weak self] _ in
                guard let self else { return }
                
                NSLayoutConstraint.deactivate(signInConstraints)         // 로그인 화면 제약 해제 (완료 후 클로저에서 실행해야함)
                
                signInViewController.view.removeFromSuperview()  // 로그인 View 제거
                signInViewController.removeFromParent()          // 자식 관계 해제
                
                self.signInConstraints.removeAll()                // 사용한 제약 참조 제거
                self.signInViewController = nil                   // 로그인 VC 참조 제거
                self.viewModel.action(input: .startApp)           // 앱 시작 상태 다시 확인
            }
        )
    }
    
    // MARK: - 로고 로딩 애니메이션 시작
    private func startLogoLoadingAnimation() {
        UIView.animate(
            withDuration: 0.7,     // 원래 크기에서 88%까지 줄어드는 데 걸리는 시간
            delay: 0,               // 지연 없이 바로 애니메이션 시작
            options: [
                .autoreverse,       // 축소 애니메이션이 끝나면 반대 방향으로 실행
                .repeat,            // 작아졌다 커지는 애니메이션을 계속 반복
                .curveEaseInOut,    // 애니메이션의 시작과 끝을 부드럽게 처리
                .allowUserInteraction   // 애니메이션 실행 중에도 사용자 입력 허용
            ]
        ) {
            // 로고의 가로와 세로 크기를 원래 크기의 88%로 축소
            self.logoImageView.transform = CGAffineTransform(
                scaleX: 0.88,
                y: 0.88
            )
        }
    }

    // MARK: - 로고 로딩 애니메이션 종료
    private func stopLogoLoadingAnimation(
        // 로고 애니메이션이 완전히 끝난 후 실행할 선택적 클로저
        completion: (() -> Void)? = nil
    ) {
        logoImageView.layer.removeAllAnimations()   // .repeat로 실행 중인 로고 애니메이션을 즉시 제거

        UIView.animate(
            withDuration: 0.2,      // 로고를 원래 크기로 복구하는 데 걸리는 시간
            animations: {
                self.logoImageView.transform = .identity    // transform을 적용하기 전의 원래 크기와 상태로 복구
            },

            completion: { _ in
                // 원래 크기로 돌아오는 애니메이션이 끝나면
                // 외부에서 전달받은 다음 작업을 실행
                completion?()
            }
        )
    }
}

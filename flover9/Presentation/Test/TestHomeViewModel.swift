//
//  TestHomeViewModel.swift
//  flover9
//

import Foundation

// MARK: - 테스트 홈 화면의 로그아웃과 회원탈퇴 동작을 처리하는 ViewModel
@MainActor
final class TestHomeViewModel {
    
    // MARK: - 화면에서 전달받을 사용자 입력
    enum Input {
        case signOutTapped                                      // 로그아웃 버튼 선택
        case deleteAccountAuthorizationCompleted(
            Result<AppleSignInCredential, AuthError>
        )                                                       // 회원탈퇴용 Apple 재인증 결과
    }
    
    // MARK: - 화면에 전달할 현재 처리 상태
    enum State {
        case idle                                               // 사용자 입력 대기
        case loading                                            // 서버 요청 처리 중
    }
    
    // MARK: - Coordinator에 전달할 화면 경로
    enum Route {
        case resetApp                                           // 앱 전체 객체 그래프 재생성
        case failed(title: String, message: String)             // 오류 Alert 표시
    }
    
    var onStateChanged: ((State) -> Void)?                      // 화면 상태 전달
    var onRoute: ((Route) -> Void)?                             // Coordinator 경로 전달
    
    private let signOutUseCase: SignOutUseCaseProtocol          // 로그아웃 처리 객체
    private let deleteAccountUseCase: DeleteAccountUseCaseProtocol // 회원탈퇴 처리 객체
    
    // MARK: - 테스트에 사용할 UseCase 주입
    init(
        signOutUseCase: SignOutUseCaseProtocol,
        deleteAccountUseCase: DeleteAccountUseCaseProtocol
    ) {
        self.signOutUseCase = signOutUseCase                    // 로그아웃 UseCase 보관
        self.deleteAccountUseCase = deleteAccountUseCase        // 회원탈퇴 UseCase 보관
    }
    
    // MARK: - 화면 입력에 맞는 동작 실행
    func action(input: Input) {
        switch input {
        case .signOutTapped:
            Task { [weak self] in
                await self?.signOut()                           // 비동기 로그아웃 실행
            }
            
        case .deleteAccountAuthorizationCompleted(let result):
            Task { [weak self] in
                await self?.deleteAccount(with: result)         // Apple 재인증 결과로 탈퇴 실행
            }
        }
    }
    
    // MARK: - 현재 Supabase 세션 로그아웃
    private func signOut() async {
        onStateChanged?(.loading)                               // 중복 입력 차단 시작
        
        do {
            try await signOutUseCase.execute()                  // Supabase 로그아웃 요청
            onRoute?(.resetApp)                                 // 성공 후 앱 전체 재시작
        } catch {
            onStateChanged?(.idle)                              // 실패 시 버튼 다시 활성화
            onRoute?(
                .failed(
                    title: "로그아웃 오류",
                    message: errorMessage(error)
                )
            )
        }
    }
    
    // MARK: - Apple 연결 해제와 Supabase 회원탈퇴
    private func deleteAccount(
        with result: Result<AppleSignInCredential, AuthError>
    ) async {
        switch result {
        case .success(let credential):
            onStateChanged?(.loading)                           // 중복 입력 차단 시작
            
            do {
                try await deleteAccountUseCase.execute(
                    credential: credential                      // 새 Apple 인증 코드 전달
                )
                onRoute?(.resetApp)                             // 성공 후 앱 전체 재시작
            } catch {
                onStateChanged?(.idle)                          // 실패 시 버튼 다시 활성화
                onRoute?(
                    .failed(
                        title: "회원탈퇴 오류",
                        message: errorMessage(error)
                    )
                )
            }
            
        case .failure(.cancelled):
            onStateChanged?(.idle)                              // 사용자 취소는 Alert 없이 복귀
            
        case .failure(let error):
            onStateChanged?(.idle)                              // Apple 인증 실패 후 입력 복구
            onRoute?(
                .failed(
                    title: "Apple 인증 오류",
                    message: errorMessage(error)
                )
            )
        }
    }
    
    // MARK: - 테스트 화면에 표시할 오류 문구 생성
    private func errorMessage(_ error: Error) -> String {
        if let authError = error as? AuthError {
            switch authError {
            case .cancelled:
                return "Apple 인증이 취소되었습니다."
            case .unauthenticated:
                return "로그인 정보를 확인할 수 없습니다."
            case .invalidAppleCredential:
                return "Apple 인증 정보가 올바르지 않습니다."
            case .sessionExpired:
                return "로그인 세션이 만료되었습니다."
            case .networkUnavailable:
                return "네트워크 연결을 확인해 주세요."
            case .serverUnavailable:
                return "서버에 연결할 수 없습니다. 잠시 후 다시 시도해 주세요."
            case .accountDeletionFailed:
                return "회원탈퇴 처리에 실패했습니다."
            case .unknown:
                return "알 수 없는 오류가 발생했습니다."
            }
        }
        
        return error.localizedDescription                       // 분류되지 않은 오류 안내
    }
}

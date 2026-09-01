//
//  SetListViewModel.swift
//  flover9
//
//  Created by 박선린 on 9/1/26.
//

import Foundation

@MainActor
final class SetListViewModel {
    // MARK: - Input
    enum Input {
        case signOutTapped
        case deleteAccountAuthorizationCompleted(
            Result<AppleSignInCredential, AuthError>
        )
    }

    // MARK: - Route
    enum Route {
        case failed(msg: String)
        case signOut
        case deleteAccount
        case roleButton
    }
    
    enum State {
        case idle
        case loading
        case insufficientPermission // 사용자에게 접근 권한이 없음(UseRole 제한)
    }
    
    
    // MARK: - Usecase
    /// 로그아웃
    private let signOutUseCase: SignOutUseCase
    
    /// 회원 탈퇴
    private let deleteAccountUseCase: DeleteAccountUseCaseProtocol
    
    // MARK: - Properties
    var onRoute: ((Route) -> Void)?
    
    var onState: ((State) -> Void)?
    
    
    // MARK: - Initializer
    init(
        signOutUseCase: SignOutUseCase,
        deleteAccountUseCase: DeleteAccountUseCaseProtocol
    ) {
        self.signOutUseCase = signOutUseCase
        self.deleteAccountUseCase = deleteAccountUseCase
    }
    
    // MARK: - Deinit
    deinit {
        print("SetListViewModel deinit")
    }

    func action(_ input: Input) {
        switch input {
        case .signOutTapped:
            Task { [weak self] in
                await self?.signOut()
            }

        case .deleteAccountAuthorizationCompleted(let result):
            Task { [weak self] in
                await self?.deleteAccount(with: result)
            }
        }
    }
    
    private func signOut() async {
        onState?(.loading)

        do {
            // 로그아웃
            try await signOutUseCase.execute()
            
            // 화면 초기화 이벤트 전달
            onRoute?(.signOut)
        } catch {
            onState?(.idle)
            onRoute?(.failed(msg: errorMessage(error)))
        }
    }
    
    
    // MARK: - 나중에 상세화면에서 별도의 동의를 받은 후 진행해야함
    private func deleteAccount(
        with result: Result<AppleSignInCredential, AuthError>
    ) async {
        switch result {
        case .success(let credential):
            onState?(.loading)

            do {
                // 탈퇴 직전에 새로 받은 일회용 Apple 인증 코드만 사용합니다.
                try await deleteAccountUseCase.execute(credential: credential)
                onRoute?(.deleteAccount)
            } catch {
                onState?(.idle)
                onRoute?(.failed(msg: errorMessage(error)))
            }

        case .failure(.cancelled):
            onState?(.idle)

        case .failure(let error):
            onState?(.idle)
            onRoute?(.failed(msg: errorMessage(error)))
        }
    }

    private func errorMessage(_ error: Error) -> String {
        guard let authError = error as? AuthError else {
            return error.localizedDescription
        }

        switch authError {
        case .cancelled:
            return "Apple 인증이 취소되었습니다."
        case .unauthenticated:
            return "로그인 정보를 확인할 수 없습니다. 다시 로그인해 주세요."
        case .invalidAppleCredential:
            return "Apple 인증 정보가 올바르지 않습니다."
        case .sessionExpired:
            return "로그인 세션이 만료되었습니다. 다시 로그인해 주세요."
        case .networkUnavailable:
            return "네트워크 연결을 확인해 주세요."
        case .serverUnavailable:
            return "서버에 연결할 수 없습니다. 잠시 후 다시 시도해 주세요."
        case .accountDeletionFailed:
            return "회원탈퇴 처리에 실패했습니다. 잠시 후 다시 시도해 주세요."
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
}

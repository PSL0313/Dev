//
//  SignInViewModel.swift
//  flover9
//
//  Created by 박선린 on 7/28/26.
//
import Foundation

@MainActor
final class SignInViewModel {
    // MARK: - Coordinator에 전달할 화면 경로
    enum Route {
        case authenticationCompleted
        case failed(title: String,message: String)
    }

    // MARK: - 로그인 화면 입력
    enum Input {
        case appleSignInCompleted(Result<AppleSignInCredential, AuthError>)
    }

    var onRoute: ((Route) -> Void)?              // Coordinator에 경로 전달

    
    private let authenticateWithAppleUseCase: AuthenticateWithAppleUseCaseProtocol
    private let errorLogger: ErrorLogging

    init(authenticateWithAppleUseCase: AuthenticateWithAppleUseCaseProtocol, errorLogger: ErrorLogging) {
        self.authenticateWithAppleUseCase = authenticateWithAppleUseCase
        self.errorLogger = errorLogger
    }

    // MARK: - Deinit
    deinit { print("SignInViewModel deinit") }
    
    func action(input: Input) {
        switch input {
        case .appleSignInCompleted(let result):
            Task { [weak self] in
                await self?.handleAppleSignInResult(result)           // Apple 인증 결과 처리
            }

        }
    }
    
    // MARK: - 애플로그인(회원가입) 요청 결과 처리
    private func handleAppleSignInResult(_ result: Result<AppleSignInCredential, AuthError>) async {
        switch result {
        case .success(let credential):
            await signInWithApple(credential)
            
        case .failure(.cancelled):
            return                                      // 사용자가 닫은 경우 오류 화면을 표시하지 않음
            
        case .failure(let error):
            onRoute?(.failed(title: "Error", message: error.userMessage))// 인증 실패 상태 전달
        }
    }
    
    
    // MARK: - 애플 로그인(회원가입) 성공 후 수파베이스 Auth 세션 요청 및 프로필 데이터 요청
    private func signInWithApple(_ credential: AppleSignInCredential) async {
        do {
            try await authenticateWithAppleUseCase.execute(
                credential: credential
            )                                                   // Supabase 인증과 세션 저장 완료까지 대기
            
            onRoute?(.authenticationCompleted)                 // 완료 후 런치 로딩 화면으로 복귀
        } catch let error as AuthError {
            await errorLogger.record(error)             // Firebase에 필요한 오류만 기록
            onRoute?(
                .failed(
                    title: "로그인 오류",
                    message: error.userMessage
                )
            )
        } catch let error as ProfileError {
            await errorLogger.record(error)             // Firebase에 필요한 오류만 기록
            onRoute?(
                .failed(
                    title: "프로필 오류",
                    message: error.userMessage
                )
            )
        } catch {
            await errorLogger.record(AuthError.unknown)             // Firebase에 필요한 오류만 기록
            onRoute?(
                .failed(
                    title: "오류",
                    message: "알 수 없는 오류가 발생하였습니다. 개발자에게 문의해주세요."
                )
            )
        }
    }
}

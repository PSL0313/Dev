//
//  AppleSignInService.swift
//  flover9
//
//  Created by 박선린 on 7/29/26.
//

import AuthenticationServices
import CryptoKit
import Security

class AppleSignInService: NSObject, ASAuthorizationControllerDelegate {
    // MARK: - typealias
    typealias Completion = (Result<AppleSignInCredential, AuthError>) -> Void
    
    // MARK: - Completion
    private var completion: Completion?           // 인증 결과 전달 클로저
    
    // MARK: - Property
    private var currentNonce: String?
    
    // MARK: - VC에서 호출(시작요청)할 메서드
    func startAppleSignIn(viewController: ASAuthorizationControllerPresentationContextProviding,completion: @escaping Completion) {
        // 로그인 요청마다 새로운 원본 nonce 생성
        let rawNonce = UUID().uuidString

        // 인증 결과가 돌아올 때 사용할 수 있도록 보관
        currentNonce = rawNonce
        
        // 인증 결과 전달 동작 보관
        self.completion = completion
        
        // Apple 로그인 요청 생성
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        // Apple에는 해시 처리된 nonce 전달
        request.nonce = sha256(rawNonce)

        let controller = ASAuthorizationController(
            authorizationRequests: [request]
        )

        controller.delegate = self
        controller.presentationContextProvider = viewController
        controller.performRequests()
    }
    
    /* 매개변수 역할(controller, authorization)
     - controller -
        우리가 실행했던 ASAuthorizationController
        보통 결과 처리에서는 직접 사용할 일이 많지 않음

     - authorization -
        Apple이 반환한 인증 결과
        내부의 credential에서 사용자 정보와 토큰을 가져옴
     let credential = authorization.credential as? ASAuthorizationAppleIDCredential
        
     ====아래는 credential에서 가져올 수 있는 대표적인 정보들====
        credential.user
        credential.identityToken
        credential.authorizationCode
        credential.fullName
        credential.email
     =================================================*/
    
    // MARK: - 인증 성공 함수
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard
            let credential = authorization.credential
                as? ASAuthorizationAppleIDCredential,

            // Apple이 발급한 인증 토큰
            let tokenData = credential.identityToken,
            let identityToken = String(
                data: tokenData,
                encoding: .utf8
            ),
            let codeData = credential.authorizationCode,
            let authorizationCode = String(
                    data: codeData,
                    encoding: .utf8
            ),

            // 요청 전에 보관했던 원본 nonce
            let rawNonce = currentNonce
        else {
            finish(with: .failure(.invalidAppleCredential))
            return
        }

        // ViewModel에 로그인 요청 전달
        let appleCredential = AppleSignInCredential(
            userIdentifier: credential.user,
            identityToken: identityToken,
            authorizationCode: authorizationCode,
            rawNonce: rawNonce,
            email: credential.email,
            fullName: credential.fullName
        )
        
        // 종료 및 VC에게 전달
        finish(with: .success(appleCredential))
    }

    // MARK: - 인증 실패 및 취소시 동작하는 함수
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        /* 주요 역할은:
        nonce 제거
        로딩 상태 종료
        실패 결과 전달
        사용자 취소와 실제 오류 구분 */
        
        if let authorizationError = error as? ASAuthorizationError,
           authorizationError.code == .canceled {
            finish(
                with: .failure(.cancelled)
            )
        } else {
            finish(
                with: .failure(.invalidAppleCredential)
            )
        }
    }
    
    // MARK: - 인증 결과 전달 및 임시 상태 정리
    private func finish(
        with result: Result<AppleSignInCredential, AuthError>
    ) {
        let completion = completion                   // 현재 클로저 임시 보관

        currentNonce = nil                            // 사용한 nonce 제거
        self.completion = nil                         // 클로저 참조 제거

        completion?(result)                           // 인증 결과 전달
    }
}

extension AppleSignInService {
    
    // MARK: - 키체인 저장
    func saveUserInKeychain(_ userIdentifier: String) {
        let data = Data(userIdentifier.utf8)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Bundle.main.bundleIdentifier ?? "Flover9",
            kSecAttrAccount as String: "appleUserIdentifier"
        ]

        // 기존 값이 있다면 갱신
        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]

        let status = SecItemUpdate(
            query as CFDictionary,
            attributes as CFDictionary
        )

        // 기존 값이 없으면 새로 저장
        if status == errSecItemNotFound {
            var newQuery = query
            newQuery[kSecValueData as String] = data

            SecItemAdd(
                newQuery as CFDictionary,
                nil
            )
        }
    }
    
    // MARK: - sha256 암호화
    private func sha256(_ input: String) -> String {
        let data = Data(input.utf8)
        let hashedData = SHA256.hash(data: data)

        return hashedData.map {
            String(format: "%02x", $0)
        }
        .joined()
    }
}

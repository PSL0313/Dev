//
//  AppleSignInCredential.swift
//  flover9
//
//  Created by 박선린 on 7/28/26.
//
import Foundation


// MARK: - Apple 인증 결과를 Domain에 전달하는 객체
struct AppleSignInCredential: Sendable, Equatable {
    let userIdentifier: String       // Apple 사용자 고유 식별자
    let identityToken: String        // Supabase 로그인에 사용하는 토큰
    let authorizationCode: String?   // Apple 토큰 교환에 사용하는 인증 코드
    let rawNonce: String             // 로그인 요청 검증에 사용한 원본 nonce
    let email: String?               // 최초 인증 시 제공될 수 있는 이메일
    let fullName: PersonNameComponents?        // 최초 인증 시 제공될 수 있는 이름
}

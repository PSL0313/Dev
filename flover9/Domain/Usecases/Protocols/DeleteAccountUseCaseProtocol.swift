//
//  DeleteAccountUseCaseProtocol.swift
//  flover9
//
//  Created by 박선린 on 7/30/26.
//


protocol DeleteAccountUseCaseProtocol {
    func execute(
        credential: AppleSignInCredential
    ) async throws
}

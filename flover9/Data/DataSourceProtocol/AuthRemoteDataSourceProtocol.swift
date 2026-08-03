//
//  AuthRemoteDataSourceProtocol.swift
//  Flover9
//
//  Created by 박선린 on 4/16/26.
//


protocol AuthRemoteDataSourceProtocol {
    func hasValidSession() async throws -> Bool
    func signOut() async throws
    func signIn(email: String, password: String) async throws
}
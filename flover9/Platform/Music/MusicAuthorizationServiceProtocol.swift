//
//  MusicAuthorizationServiceProtocol.swift
//  flover9
//
//  Created by 박선린 on 9/1/26.
//
import MusicKit


protocol MusicAuthorizationServiceProtocol {
    var currentStatus: MusicAuthorization.Status { get }
    
    var canRequestAuthorization: MusicAuthorizationState { get }
    
    func requestAuthorization() async -> MusicAuthorizationState
}

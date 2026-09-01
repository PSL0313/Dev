//
//  LaunchViewModel.swift
//  flover9
//
//  Created by 박선린 on 7/27/26.
//
import Foundation


@MainActor
final class LaunchViewModel {
    
    // MARK: - Input, State, Route
    enum Input {
        case startApp
    }
    
    enum State {
        case loading
        case loginRequired
        case updateRequired
    }
    
    enum Route {
        case onLoginRequired                        // 로그인 필요 → Coordinator
        case failed(title: String,message: String)  // 실패(에러)
        case main                                   // main으로 이동
        case updateRequired                         // 앱 업데이트 필요
        case maintenance(message: String)           // 점검
    }
    
    var onRoute: ((Route) -> Void)?         // Route → Coordinator
    
    var onStateChanged: ((State) -> Void)?  // 뷰컨트롤러가 State 받을 이벤트 → VC
    
    // MARK: - Usecases
    private let restoreUserSessionUseCase: RestoreUserSessionUseCaseProtocol
    private let checkAppAvailabilityUseCase: CheckAppAvailabilityUseCaseProtocol
    
    private let musicAuthorizationService: MusicAuthorizationService
    
    private let errorLogger: ErrorLogging
    
    private var launchTask: Task<Void, Never>?      // 현재 실행 중인 앱 시작 작업
    
    init(checkAppAvailabilityUseCase: CheckAppAvailabilityUseCaseProtocol,
         restoreUserSessionUseCase: RestoreUserSessionUseCaseProtocol,
         errorLogger: ErrorLogging,
         musicAuthorizationService: MusicAuthorizationService
    ) {
        self.checkAppAvailabilityUseCase = checkAppAvailabilityUseCase
        self.restoreUserSessionUseCase = restoreUserSessionUseCase
        self.errorLogger = errorLogger
        self.musicAuthorizationService = musicAuthorizationService
    }
    
    // MARK: - Deinit
    deinit {
        launchTask?.cancel()                        // ViewModel 해제 시 진행 중인 작업 종료
        print("LaunchViewModel deinit")
    }
    
    // MARK: - action
    func action(input event: Input) {
        switch event {
        case .startApp:
            launchTask?.cancel()                        // 이전 시작 작업과의 경쟁 방지
            onStateChanged?(.loading)
            launchTask = Task { [weak self] in
                guard let self else { return }
                
                let isMusicAuthorized = await checkMusicAuthorizationStatus()
                
                if isMusicAuthorized == false { return }
                
                await self.startLaunchProcess()         // 앱 시작 프로세스 시작
            }
        }
    }
    
    private func checkMusicAuthorizationStatus() async -> Bool {
        switch musicAuthorizationService.canRequestAuthorization {
        case .granted:
            return true
        case .requestRequired:
            let result = await musicAuthorizationService.requestAuthorization()
            guard result != .granted else { return true }
            return false
        case .unavailable:
            onRoute?(.failed(title: "오류", message: "알 수 없는 문제로 애플 뮤직 권한을 확인할 수 없습니다. 잠시 후 다시 시도해주세요."))
            return false
        case .denied:
            onRoute?(.failed(title: "권한 요청", message: "저작권 보호를 위해 Apple Music을 통해 음악 정보를 제공하고 있어요.계속 이용하려면 설정에서 Apple Music 접근을 허용해 주세요."))
            return false
            
            
        }
    }
    
    private func startLaunchProcess() async {
        do {
            let isAppAvailable = await checkAppAvailabilityUseCase.execute()
            try Task.checkCancellation()        // 취소된 작업은 경로를 변경하지 않음
            switch isAppAvailable {
            case .maintenance(let message): //점검 중
                onRoute?(.maintenance(message: message))
            case .updateRequired:   // 앱 업데이트 필요
                onStateChanged?(.updateRequired)
                onRoute?(.updateRequired)
            case .available:    // 서비스 정상 동작 중
                let isLogin = try await restoreUserSessionUseCase.execute()
                try Task.checkCancellation()    // 최신 실행 결과만 화면에 반영
                
                switch isLogin {
                case true:
                    onRoute?(.main)
                case false:
                    onStateChanged?(.loginRequired)
                    onRoute?(.onLoginRequired)
                }
            }
        } catch let error as AuthError {
            guard !Task.isCancelled else { return }
            await errorLogger.record(error)
            onRoute?(.failed(title: "Error", message: error.userMessage))// 인증 실패 상태 전달
        } catch let error as ProfileError {
            guard !Task.isCancelled else { return }
            await errorLogger.record(error)
            onRoute?(.failed(title: "Error", message: error.userMessage))// 인증 실패 상태 전달
        } catch {
            guard !Task.isCancelled else { return }
            await errorLogger.record(AuthError.unknown)
            onRoute?(.failed(title: "Error", message: "알 수 없는 오류가 발생하였습니다. 개발자에게 문의해주세요."))// 인증 실패 상태 전달
        }
    }
}

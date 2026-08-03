import Foundation
import Supabase

/// 앱 전체 의존성을 조립하는 Composition Root입니다.
///
/// 기능을 추가할 때 DataSource → Repository → UseCase 순서로 생성하고,
/// 각 Feature에서 필요한 의존성만 노출합니다.
final class AppDIContainer {
    // MARK: - 팔수 생성 객체
    // MARK: - 앱 실행 중 공유할 사용자 상태 저장소
    private let userSessionStore = UserSessionStore()
    
    // MARK: - SupabaseClient
    private lazy var supabaseClient: SupabaseClient = {
        return SupabaseClient(
            supabaseURL: AppConfiguration.supabaseURL,                         // 설정 파일의 프로젝트 URL
            supabaseKey: AppConfiguration.supabasePublishableKey              // 설정 파일의 공개 클라이언트 키
        )
    }()
    
    private lazy var authRepository: AuthRepositoryProtocol = {
        SupabaseAuthRepository(client: supabaseClient)
    }()
    
    private lazy var profileRepository: ProfileRepositoryProtocol = {
        SupabaseProfileRepository(client: supabaseClient)
    }()
    
    // Remote Config 저장소
    private lazy var remoteConfigRepository:
        RemoteConfigRepositoryProtocol = {
            FirebaseRemoteConfigRepository()
        }()

    
    init() {}
     
    // MARK: - Usecases
    // 앱 접속 가능 여부 확인 UseCase
    private lazy var checkAppAvailabilityUseCase:
        CheckAppAvailabilityUseCaseProtocol = {
            CheckAppAvailabilityUseCase(
                repository: remoteConfigRepository
            )
        }()
    
    private lazy var authenticateWithAppleUseCase: AuthenticateWithAppleUseCaseProtocol = {
        AuthenticateWithAppleUseCase(authRepository: authRepository, profileRepository: profileRepository, userSessionStore: userSessionStore)
    }()
    
    private lazy var deleteAccountUseCase: DeleteAccountUseCaseProtocol = {
        DeleteAccountUseCase(authRepository: authRepository)
    }()
    
    private lazy var signOutUseCase: SignOutUseCaseProtocol = {
        SignOutUseCase(authRepository: authRepository)
    }()
    
    private lazy var restoreUserSessionUseCase: RestoreUserSessionUseCaseProtocol = {
        RestoreUserSessionUseCase(
            authRepository: authRepository,
            profileRepository: profileRepository,
            userSessionStore: userSessionStore)
    }()
    
    // MARK: - get ViewModels
    func getLaunchViewModel() -> LaunchViewModel {
        return LaunchViewModel(
            checkAppAvailabilityUseCase: checkAppAvailabilityUseCase,
            restoreUserSessionUseCase: restoreUserSessionUseCase
        )
    }
    
    func getSignInViewModel() -> SignInViewModel {
        return SignInViewModel(authenticateWithAppleUseCase: authenticateWithAppleUseCase)
    }
    
    // MARK: - 테스트 홈 화면 ViewModel 생성
    func getTestHomeViewModel() -> TestHomeViewModel {
        TestHomeViewModel(
            signOutUseCase: signOutUseCase,                      // 로그아웃 기능 주입
            deleteAccountUseCase: deleteAccountUseCase           // 회원탈퇴 기능 주입
        )
    }
    
}

extension AppDIContainer {
    // MARK: - Apple 인증 화면을 처리하는 서비스 생성
    func makeAppleSignInService() -> AppleSignInService {
        AppleSignInService()                          
    }
}

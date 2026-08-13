import Foundation
import Supabase

/// 앱 전체 의존성을 조립하는 Composition Root입니다.
///
/// 기능을 추가할 때 DataSource → Repository → UseCase 순서로 생성하고,
/// 각 Feature에서 필요한 의존성만 노출합니다.
final class AppDIContainer {
    // MARK: - 필수 생성 객체
    // MARK: - 앱 실행 중 공유할 사용자 상태 저장소
    private let userSessionStore = UserSessionStore()

    // MARK: - SupabaseClient
    private lazy var supabaseClient: SupabaseClient = {
        return SupabaseClient(
            supabaseURL: AppConfiguration.supabaseURL,                         // 설정 파일의 프로젝트 URL
            supabaseKey: AppConfiguration.supabasePublishableKey              // 설정 파일의 공개 클라이언트 키
        )
    }()
    
    // MARK: - Firebase 오류 기록 객체
    private lazy var errorLogger: ErrorLogging = {
        FirebaseErrorLogger()
    }()

    // MARK: - Datasource
    private lazy var feedRemoteDataSource: FeedRemoteDataSourceProtocol = {
        return SupabaseFeedRemoteDataSource(supabase: self.supabaseClient)
    }()

    // DataSource
    private lazy var memberRemoteDataSource: MemberRemoteDataSourceProtocol = {
        SupabaseMemberRemoteDataSource(
            supabaseClient: supabaseClient
        ) // 공유 Supabase 클라이언트 주입
    }()

    // 일정 원격 DataSource
    private lazy var scheduleRemoteDataSource: ScheduleRemoteDataSourceProtocol = {
        SupabaseScheduleRemoteDataSource(
            supabaseClient: supabaseClient
        ) // 공유 Supabase 클라이언트 주입
    }()
    
    // MARK: - Repository
    private lazy var authRepository: AuthRepositoryProtocol = {
        SupabaseAuthRepository(client: supabaseClient)
    }()
    
    private lazy var profileRepository: ProfileRepositoryProtocol = {
        SupabaseProfileRepository(client: supabaseClient)
    }()
    
    private lazy var feedRepository: FeedRepositoryProtocol = {
        return SupabaseFeedRepository(datasource: self.feedRemoteDataSource)
    }()

    // 멤버 Repository
    private lazy var memberRepository: MemberRepositoryProtocol = {
        MemberRepository(
            dataSource: memberRemoteDataSource
        ) // 원격 DTO 조회 및 Domain Entity 변환 담당
    }()

    // 일정 Repository
    private lazy var scheduleRepository: ScheduleRepositoryProtocol = {
        ScheduleRepository(
            dataSource: scheduleRemoteDataSource
        ) // 원격 일정 DTO 조회 및 Domain 모델 변환 담당
    }()
    
    // Remote Config 저장소
    private lazy var remoteConfigRepository:RemoteConfigRepositoryProtocol = {
        FirebaseRemoteConfigRepository()
    }()

    
    init() {}
     
    // MARK: - Usecases
    // 앱 접속 가능 여부 확인 UseCase
    private lazy var checkAppAvailabilityUseCase: CheckAppAvailabilityUseCaseProtocol = {
            CheckAppAvailabilityUseCase(
                repository: remoteConfigRepository
            )
        }()
    
    private lazy var authenticateWithAppleUseCase: AuthenticateWithAppleUseCaseProtocol = {
        AuthenticateWithAppleUseCase(
            authRepository: authRepository,
            profileRepository: profileRepository,
            userSessionStore: userSessionStore
        )
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

    // 활성 멤버 목록 조회 UseCase
    private lazy var fetchMembersUseCase: FetchMembersUseCaseProtocol = {
        FetchMembersUseCase(
            memberRepository: memberRepository
        ) // Presentation에서 사용할 멤버 목록 기능 조립
    }()

    // 표지용 일정 목록 조회 UseCase
    private lazy var fetchScheduleCoversUseCase: FetchScheduleCoversUseCaseProtocol = {
        FetchScheduleCoversUseCase(
            scheduleRepository: scheduleRepository
        ) // 일정 표지 화면에 사용할 기능 조립
    }()

    // 일정 상세 정보 조회 UseCase
    private lazy var fetchScheduleDetailUseCase: FetchScheduleDetailUseCaseProtocol = {
        FetchScheduleDetailUseCase(
            scheduleRepository: scheduleRepository
        ) // 일정 상세 화면에 사용할 기능 조립
    }()
    
    // 표지 화면용 일정 목록 UseCase 제공
    func getFetchScheduleCoversUseCase() -> FetchScheduleCoversUseCaseProtocol {
        fetchScheduleCoversUseCase
    }

    // 일정 상세 화면용 UseCase 제공
    func getFetchScheduleDetailUseCase() -> FetchScheduleDetailUseCaseProtocol {
        fetchScheduleDetailUseCase
    }
    
    // MARK: - get ViewModels
    func getLaunchViewModel() -> LaunchViewModel {
        return LaunchViewModel(
            checkAppAvailabilityUseCase: checkAppAvailabilityUseCase,
            restoreUserSessionUseCase: restoreUserSessionUseCase,
            errorLogger: errorLogger
        )
    }
    
    func getSignInViewModel() -> SignInViewModel {
        return SignInViewModel(
            authenticateWithAppleUseCase: authenticateWithAppleUseCase,
            errorLogger: errorLogger
        )
    }
    
    // HomeViewModel
    func getHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            fetchMembersUseCase: fetchMembersUseCase,
            fetchScheduleCoversUseCase: fetchScheduleCoversUseCase
        )
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

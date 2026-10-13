//
//  AppDIContainer.swift
//  flover9
//
//  Created by 박선린 on 8/1/26.
//

import Foundation
import ComposableArchitecture
import Supabase

/// 앱 전체 의존성을 조립하는 Composition Root입니다.
///
/// 기능을 추가할 때 DataSource → Repository → UseCase 순서로 생성하고,
/// 각 Feature에서 필요한 의존성만 노출합니다.
final class AppDIContainer {
    // MARK: - 필수 생성 객체
    // MARK: - 앱 실행 중 공유할 사용자 상태 저장소
    let userSessionStore = UserSessionStore()

    // 애플 뮤직 앨범 스토어
    private let musicAlbumStore: MusicAlbumStoreProtocol = {
        MusicAlbumStore()
    }()

    // 좋아요를 누른 WallPaper(배경화면)을 불러오는 객체
    lazy var wallpaperFavorites = WallpaperFavoritesStore()
    
    // MARK: - SupabaseClient
    private lazy var supabaseClient: SupabaseClient = {
        return SupabaseClient(
            supabaseURL: AppConfiguration.supabaseURL,                         // 설정 파일의 프로젝트 URL
            supabaseKey: AppConfiguration.supabasePublishableKey              // 설정 파일의 공개 클라이언트 키
        )
    }()

    // MARK: - Firebase 오류 기록 객체
    private lazy var errorLogger: ErrorLogging = {
        #if FIREBASE_DISABLED
        DisabledErrorLogger()
        #else
        FirebaseErrorLogger()
        #endif
    }()

    // MARK: - Initializer
    init() {}
    
    // MARK: - Cache
    private lazy var feedCache: FeedCacheProtocol = {
        FeedCache()
    }()

    private lazy var scheduleCache: ScheduleCacheProtocol = {
        ScheduleCache()
    }()

    private lazy var mapItemCache: MapItemCacheProtocol = {
        MapItemCache()
    }()

    // MARK: - Datasource
    // 맵 아이템
    private lazy var mapItemDataSource: MapItemDataSourceProtocol = {
        AppleMapItemDataSource()
    }()

    // 피드 데이터
    private lazy var feedRemoteDataSource: FeedRemoteDataSourceProtocol = {
        return SupabaseFeedRemoteDataSource(supabase: self.supabaseClient)
    }()

    // 멤버 데이터
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

    // R2 presign과 Supabase 배치 확정을 담당하는 원격 DataSource
    private lazy var mediaStorageRemoteDataSource: MediaStorageRemoteDataSourceProtocol = {
        SupabaseMediaStorageRemoteDataSource(
            supabaseClient: supabaseClient
        )
    }()
    
    // 배경화면
    private lazy var wallpaperSource: WallpaperRemoteDataSourceProtocol = SupabaseWallpaperRemoteDataSource(client: supabaseClient)
    // 배경화면 관리
    private lazy var wallpaperAdminSource: WallpaperAdminRemoteDataSourceProtocol = SupabaseWallpaperAdminRemoteDataSource(client: supabaseClient, authorization: authorizationRepository)
    

    // MARK: - Repository
    // 맵 아이템
    private lazy var mapItemRepository: MapItemRepositoryProtocol = {
        MapItemRepository(dataSource: mapItemDataSource, cache: mapItemCache)
    }()

    // Auth
    private lazy var authRepository: AuthRepositoryProtocol = {
        SupabaseAuthRepository(client: supabaseClient)
    }()

    // 프로필
    private lazy var profileRepository: ProfileRepositoryProtocol = {
        SupabaseProfileRepository(client: supabaseClient)
    }()

    // 피드
    private lazy var feedRepository: FeedRepositoryProtocol = {
        return SupabaseFeedRepository(
            datasource: feedRemoteDataSource,
            cache: feedCache
        )
    }()

    // 멤버
    private lazy var memberRepository: MemberRepositoryProtocol = {
        MemberRepository(
            dataSource: memberRemoteDataSource
        ) // 원격 DTO 조회 및 Domain Entity 변환 담당
    }()

    // 일정
    private lazy var scheduleRepository: ScheduleRepositoryProtocol = {
        ScheduleRepository(
            dataSource: scheduleRemoteDataSource,
            cache: scheduleCache
        ) // 원격 일정 DTO 조회 및 Domain 모델 변환 담당
    }()

    // 피드 미디어 업로드 Repository
    private lazy var mediaStorageRepository: MediaStorageRepositoryProtocol = {
        MediaStorageRepository(
            dataSource: mediaStorageRemoteDataSource
        )
    }()

    // Remote Config 저장소
    private lazy var remoteConfigRepository:RemoteConfigRepositoryProtocol = {
        #if FIREBASE_DISABLED
        DevelopmentAppAvailabilityRepository()
        #else
        FirebaseRemoteConfigRepository()
        #endif
    }()

    // 프로필과 독립된 권한 저장소입니다. 화면 진입과 관리 작업마다 최신 값을 조회합니다.
    private lazy var authorizationRepository: AuthorizationRepositoryProtocol = AuthorizationRepository(
        source: SupabaseAuthorizationRemoteDataSource(client: supabaseClient))
    private lazy var authorizationUseCase: AuthorizationUseCaseProtocol = AuthorizationUseCase(repository: authorizationRepository)

    func getRoleManagementViewModel() -> RoleManagementViewModel {
        RoleManagementViewModel(useCase: authorizationUseCase)
    }

    // MARK: - 관리자 기능 의존성 조립
    private lazy var adminRepository: AdminRepositoryProtocol = {
        AdminRepository(
            dataSource: SupabaseAdminRemoteDataSource(client: supabaseClient),
            feedCache: feedCache,
            scheduleRepository: scheduleRepository
        )
    }()
    
    // 배경화면
    private lazy var wallpaperRepository: WallpaperRepositoryProtocol = WallpaperRepository(source: wallpaperSource)
    
    // 배경화면 관리
    private lazy var wallpaperAdminRepository: WallpaperAdminRepositoryProtocol = WallpaperAdminRepository(source: wallpaperAdminSource)
    
    private lazy var adminUseCase: AdminUseCaseProtocol = {
        AdminUseCase(repository: adminRepository, createFeedUseCase: createFeedUseCase, authorization: authorizationUseCase)
    }()

    func getAdminDashboardViewModel() -> AdminDashboardViewModel {
        AdminDashboardViewModel(useCase: adminUseCase)
    }

    func getAdminListViewModel(category: AdminCategory) -> AdminListViewModel {
        AdminListViewModel(category: category, useCase: adminUseCase, logger: errorLogger)
    }

    func getAdminEditorViewModel(mode: AdminEditorMode) -> AdminEditorViewModel {
        AdminEditorViewModel(mode: mode, useCase: adminUseCase, logger: errorLogger)
    }

    // MARK: - Usecases
    private lazy var mapItemUseCase: MapItemUseCaseProtocol = {
        MapItemUseCase(repository: mapItemRepository)
    }()

    func getMapItemUseCase() -> MapItemUseCaseProtocol {
        mapItemUseCase
    }

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
        DeleteAccountUseCase(
            authRepository: authRepository,
            userSessionStore: userSessionStore
        )
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

    // 피드 읽기 전용 레포지토리
    private lazy var feedReadUseCase: FeedReadUseCaseProtocol = {
        FeedReadUseCase(
            feedRepository: feedRepository
        )
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
    
    private lazy var fetchScheduleStartDatesUsecase: FetchScheduleStartDatesProtocol = {
        FetchScheduleStartDatesUseCase(
            repository: scheduleRepository
        )
    }()

    // 피드와 첨부 미디어 일괄 생성 UseCase
    private lazy var createFeedUseCase: CreateFeedUseCaseProtocol = {
        CreateFeedUseCase(repository: mediaStorageRepository)
    }()

    // 피드 미디어 삭제 UseCase
    private lazy var deleteFeedMediaUseCase: DeleteFeedMediaUseCaseProtocol = {
        DeleteFeedMediaUseCase(repository: mediaStorageRepository)
    }()

    // 표지 화면용 일정 목록 UseCase 제공
    func getFetchScheduleCoversUseCase() -> FetchScheduleCoversUseCaseProtocol {
        fetchScheduleCoversUseCase
    }

    // 일정 상세 화면용 UseCase 제공
    func getFetchScheduleDetailUseCase() -> FetchScheduleDetailUseCaseProtocol {
        fetchScheduleDetailUseCase
    }

    // 피드 업로드 화면에 제공할 UseCase
    func getCreateFeedUseCase() -> CreateFeedUseCaseProtocol {
        createFeedUseCase
    }

    // 피드 편집 화면에 제공할 삭제 UseCase
    func getDeleteFeedMediaUseCase() -> DeleteFeedMediaUseCaseProtocol {
        deleteFeedMediaUseCase
    }
    
    // 배경화면 다운로드
    func makeDownloadWallpaperUseCase() -> DownloadWallpaperUseCase { DownloadWallpaperUseCase(repository: WallpaperDownloadRepository()) }

    // WallPaper 관리
    func makeManageWallpapersUseCase() -> ManageWallpapersUseCase {
        ManageWallpapersUseCase(repository: wallpaperAdminRepository)
    }
    
    func canManageWallpapers() async -> Bool {
        (try? await authorizationUseCase.current().canManageWallpapers) == true
    }
    
    // 시리즈별 검색
    func makeBrowseWallpapersUseCase() -> BrowseWallpapersUseCase {
        BrowseWallpapersUseCase(repository: wallpaperRepository)
    }
    
    func makeUpdateProfileUsecase() -> UpdateProfileUsecaseProtocol {
        UpdateProfileUsecase(
            profileRepository: profileRepository,
            userSessionStore: userSessionStore
        )
    }
    
    // MARK: - makeFeature(ComposableArchitecture)
    func makeCalendarFeature() -> CalendarFeature {
        CalendarFeature(
            fetchScheduleCoversUseCase: fetchScheduleCoversUseCase,
            fetchScheduleStartDatesUseCase: fetchScheduleStartDatesUsecase
        )
    }
    
    func makeAgreementFeature() -> AgreementFeature {
        AgreementFeature()
    }
    
    func makeNicknameFeature() -> NicknameFeature {
        NicknameFeature(updateProfileUsecase: makeUpdateProfileUsecase())
    }
    


    // MARK: - get ViewModels
    func getLaunchViewModel() -> LaunchViewModel {
        return LaunchViewModel(
            checkAppAvailabilityUseCase: checkAppAvailabilityUseCase,
            restoreUserSessionUseCase: restoreUserSessionUseCase,
            errorLogger: errorLogger,
            musicAuthorizationService: makeMusicAuthorizationService()
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
            fetchScheduleCoversUseCase: fetchScheduleCoversUseCase,
            musicAlbumStore: musicAlbumStore,
            appleMusicCatalogService: makeAppleMusicCatalogService()
        )
    }

    // MARK: - 테스트 홈 화면 ViewModel 생성
    func getTestHomeViewModel() -> TestHomeViewModel {
        TestHomeViewModel(
            signOutUseCase: signOutUseCase,                      // 로그아웃 기능 주입
            deleteAccountUseCase: deleteAccountUseCase           // 회원탈퇴 기능 주입
        )
    }

    func getMemberProfileViewModel(_ member: MemberEntity) -> MemberProfileViewModel {
        MemberProfileViewModel(
            member: member,
            FeedReadUseCase: feedReadUseCase
        )
    }

    func getScheduleDetailViewModel(scheduleID: UUID) -> ScheduleDetailViewModel {
        ScheduleDetailViewModel(
            scheduleID: scheduleID,
            fetchScheduleDetailUseCase: fetchScheduleDetailUseCase,
            mapItemUseCase: mapItemUseCase,
            errorLogger: errorLogger
        )
    }

    
    func makeWallpaperHomeViewModel() -> WallpaperHomeViewModel {
        WallpaperHomeViewModel(browse: makeBrowseWallpapersUseCase())
    }
    
    func makeWallpaperSearchViewModel() -> WallpaperSearchViewModel {
        WallpaperSearchViewModel(browse: makeBrowseWallpapersUseCase())
    }
    
    // MARK: - StoreMaker(ComposableArchitecture)
    func makeStore<T: Reducer>(
        initialState: T.State,
        feature: T
    ) -> StoreOf<T> {
        Store(initialState: initialState) {
            feature
        }
    }
    
    
}

// MARK: - Platform
extension AppDIContainer {
    // Apple 인증 화면을 처리하는 서비스 생성
    func makeAppleSignInService() -> AppleSignInService {
        AppleSignInService()
    }

    // 애플 뮤직
    func makeAppleMusicCatalogService() -> AppleMusicCatalogService {
        AppleMusicCatalogService()
    }
    
    // 애플 뮤직 권한 설정 상태와 요청 관리 객체
    func makeMusicAuthorizationService() -> MusicAuthorizationService {
        MusicAuthorizationService()
    }
}

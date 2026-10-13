#if FIREBASE_DISABLED
// Firebase 비활성화 빌드는 원격 점검·업데이트 설정 없이 실행합니다.
final class DevelopmentAppAvailabilityRepository: RemoteConfigRepositoryProtocol {
    func fetchAppAvailability() async -> AppAvailability {
        .available
    }
}
#endif

#if FIREBASE_DISABLED
// Firebase 비활성화 빌드에서는 오류를 외부 서비스로 전송하지 않습니다.
nonisolated struct DisabledErrorLogger: ErrorLogging {
    func record(_ error: AdminError) async {}
    func record(_ error: AuthError) async {}
    func record(_ error: ProfileError) async {}
    func record(_ error: MediaUploadError) async {}
    func record(_ error: ScheduleError) async {}
}
#endif

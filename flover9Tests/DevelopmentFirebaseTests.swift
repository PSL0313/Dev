import XCTest
import FirebaseCore
@testable import flover9

#if FIREBASE_DISABLED
@MainActor
final class DevelopmentFirebaseTests: XCTestCase {
    func testRunsWithoutFirebaseConfiguration() async {
        XCTAssertNil(Bundle.main.url(forResource: "GoogleService-Info", withExtension: "plist"))
        XCTAssertNil(FirebaseApp.app())
        let availability = await DevelopmentAppAvailabilityRepository().fetchAppAvailability()
        guard case .available = availability else {
            return XCTFail("Firebase-disabled builds must not depend on remote availability settings")
        }
        let logger = DisabledErrorLogger()
        await logger.record(AuthError.unknown)
        await logger.record(ProfileError.unknown)
        await logger.record(ScheduleError.unknown)
        await logger.record(MediaUploadError.unknown)
        await logger.record(AdminError.serverUnavailable)
        XCTAssertNil(FirebaseApp.app())
    }
}
#endif

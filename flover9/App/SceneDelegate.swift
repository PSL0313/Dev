import UIKit

// MARK: - 앱의 Window와 최상위 객체 그래프를 관리하는 객체
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?                           // 앱 화면을 표시할 Window

    private var appCoordinator: AppCoordinator?     // 현재 앱의 최상위 Coordinator
    private var appDIContainer: AppDIContainer?     // 현재 앱의 의존성 Container

    // MARK: - Scene 최초 연결
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else {
            return                                  // 유효한 WindowScene이 아니면 종료
        }

        let window = UIWindow(windowScene: windowScene) // 앱 Window 생성
        self.window = window                        // SceneDelegate가 Window 보관

        startAppFlow()                              // 최초 객체 그래프 생성

        window.makeKeyAndVisible()                  // Window를 화면에 표시
    }

    // MARK: - 앱 전체 객체 그래프 생성
    @MainActor
    private func startAppFlow() {
        guard let window else { return }            // Window가 없으면 실행 불가

        let container = AppDIContainer()            // 새로운 DIContainer 생성
        let coordinator = AppCoordinator(
            window: window,
            container: container
        )

        coordinator.onRequestAppReset = { [weak self] in
            Task { @MainActor [weak self] in
                self?.restartAppFlow()              // 로그아웃 성공 후 전체 교체
            }
        }

        appDIContainer = container                 // 새 DIContainer 보관
        appCoordinator = coordinator               // 새 Coordinator 보관

        coordinator.start()                        // Launch 화면부터 실행
    }

    // MARK: - 기존 객체 그래프 제거 후 새로 생성
    @MainActor
    private func restartAppFlow() {
        appCoordinator = nil                       // 기존 Coordinator 그래프 해제
        appDIContainer = nil                       // 기존 의존성 그래프 해제

        startAppFlow()                             // 새로운 객체 그래프 생성
    }
}

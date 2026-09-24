//
//  HomeCoordinator.swift
//  flover9
//
//  Created by 박선린 on 7/27/26.
//

import UIKit
import SafariServices

final class HomeCoordinator: BaseCoordinator {

    var navigationController: UINavigationController
    var onRequestAppReset: (() -> Void)?               // 앱 전체 재시작 요청
    var onReadyForShowHome: (() -> Void)?              // 초기 데이터 fetch 완료

    private let container: AppDIContainer              // 테스트 화면 의존성 생성 객체


    // 커스텀 트렌지션 델리게이트
    private let customTransitioningDelegate = CustomTransitioningDelegate()

    init(
        navigationController: UINavigationController,
        container: AppDIContainer
    ) {
        self.navigationController = navigationController
        self.container = container
    }

    override func start() {
        let viewModel = container.getHomeViewModel()
        viewModel.onRoute = { [weak self] route in
            guard let self else { return }
            switch route {
            case .fetchedHomeData:
                self.onReadyForShowHome?()
            case .failed(let msg):
                self.showAlert(title: "에러", message: msg)
            case .moveToMemberProfileView(let member):
                self.showMemberProfileView(member: member)
            case .moveToScheduleDetailView(let scheduleId):
                self.showScheduleDetail(scheduleId: scheduleId)
            case .moveToMelonMusicWave:
                self.presentMusicWave()
            }
        }

        let viewController = HomeViewController(viewModel: viewModel)

        navigationController.setViewControllers(
            [viewController],
            animated: false
        )
        viewModel.action(.start)
    }

    func start1() {
        let viewModel = container.getTestHomeViewModel()
        viewModel.onRoute = { [weak self] route in
            switch route {
            case .resetApp:
                self?.onRequestAppReset?()                       // SceneDelegate까지 재시작 전달
            case .failed(let title, let message):
                self?.showAlert(
                    title: title,
                    message: message
                )
            }
        }

        let viewController = TestHomeViewController(
            viewModel: viewModel,
            appleSignInService: container.makeAppleSignInService()
        )

        navigationController.setViewControllers(
            [viewController],
            animated: false
        )
    }

    // MARK: - Alert 표시
    private func showAlert(
        title: String,
        message: String
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: "확인",
                style: .default
            )
        )

        navigationController.present(alert, animated: true)
    }

    // MARK: - 멤버 프로필(피드) 이동
    private func showMemberProfileView(member: MemberEntity) {
        let viewModel = container.getMemberProfileViewModel(member)
        viewModel.onRoute = { [weak self] route in
            switch route {
            case .moveToFeedDetail(let feed, let mediaItems):
                self?.showFeedDetail(feed: feed, mediaItems: mediaItems)
            case .failed(let message):
                self?.showAlert(title: "에러", message: message)
            }
        }

        let vc = MemberProfileViewViewController(viewModel: viewModel)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController.pushViewController(vc, animated: true)
    }

    // MARK: - Detail Feed
    private func showFeedDetail(
        feed: FeedEntity,
        mediaItems: [FeedImageEntity]
    ) {
        let viewController = FeedDetailBottomSheetViewController(
            feed: feed,
            mediaItems: mediaItems
        )

        customTransitioningDelegate.attachInteraction(
            to: viewController
        )

        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = customTransitioningDelegate

        navigationController.present(
            viewController,
            animated: true
        )
    }
    
    // MARK: - Detail Schedule
    private func showScheduleDetail(scheduleId: UUID) {
        let viewModel = container.getScheduleDetailViewModel(
            scheduleID: scheduleId
        )
        viewModel.onRoute = { [weak self] route in
            switch route {
            case .openReservation(let url):
                UIApplication.shared.open(url) { [weak self] opened in
                    guard !opened else { return }
                    Task { @MainActor in
                        self?.showAlert(title: "페이지를 열 수 없어요", message: "잠시 후 다시 시도해 주세요.")
                    }
                }
            case .calendarAddFailed(let msg):
                self?.showAlert(title: "실패", message: msg)
            }
        }

        let vc = DetailScheduleViewController(viewModel: viewModel)
        self.navigationController.modalPresentationStyle = .pageSheet
        self.navigationController.present(vc, animated: true)
    }
    
    // MARK: - moveToMelonMusicWave
    func presentMusicWave() {
        guard let url = URL(
            string: "https://into.melon.com/bridge/normal/musicwave/5NBXq1bGtX0CP8Qf-N_tmQ?type=channel&albumId=11564698&ajax_ts=266"
        ) else {
            return
        }

        let safari = SFSafariViewController(url: url)
        
        safari.modalPresentationStyle = .pageSheet

        if let sheet = safari.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }

        navigationController.present(safari, animated: true)
    }
}

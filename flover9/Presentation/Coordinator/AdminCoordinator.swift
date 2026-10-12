//
//  AdminCoordinator.swift
//  flover9
//
//  Created by 박선린 on 9/24/26.
//

import UIKit

// MARK: - 관리자 화면 이동과 Alert를 관리. 임시 탭 연결과 기능은 분리한다.
final class AdminCoordinator: BaseCoordinator {
    let navigationController: UINavigationController
    private let container: AppDIContainer

    init(navigationController: UINavigationController, container: AppDIContainer) {
        self.navigationController = navigationController
        self.container = container
    }

    override func start() {
        AdminStyle.configureNavigationBar(navigationController.navigationBar)
        let viewModel = container.getAdminDashboardViewModel()
        viewModel.onRoute = { [weak self] route in
            switch route {
            case .manage(let category): self?.showList(category)
            }
        }
        let viewController = AdminDashboardViewController(viewModel: viewModel)
        viewController.onManageRoles = { [weak self] in self?.showRoleManagement() }
        viewController.onManageWallpapers = { [weak self] in self?.showWallpapers() }
        navigationController.setViewControllers([viewController], animated: false)
    }

    // 역할 변경은 대상·사유·최종 확인을 거친 뒤 UseCase에서 현재 권한을 재검사합니다.
    private func showRoleManagement() {
        let model = container.getRoleManagementViewModel()
        let controller = RoleManagementViewController(viewModel: model)
        model.onMessage = { [weak self] title, message in self?.showAlert(title: title, message: message) }
        controller.onSelect = { [weak self, weak model, weak controller] member, access in
            guard let self, let model, let controller else { return }
            let alert = UIAlertController(title: member.displayName, message: "현재 역할: \(member.roleTitle)", preferredStyle: .actionSheet)
            let choices: [UserRole?] = [nil, .creator, .manager]
            for role in choices where role != member.role && access.canAssign(role, replacing: member.role) {
                alert.addAction(UIAlertAction(title: role?.title ?? "일반 회원으로 변경", style: .default) { [weak self, weak model] _ in
                    self?.requestRoleReason(member: member, role: role, transfer: false, model: model)
                })
            }
            if access.role == .admin, access.allows(.rolesTransferAdmin), access.userID != member.id {
                alert.addAction(UIAlertAction(title: "어드민 이전", style: .destructive) { [weak self, weak model] _ in
                    self?.requestRoleReason(member: member, role: .admin, transfer: true, model: model)
                })
            }
            if alert.actions.isEmpty {
                showAlert(title: "권한 확인", message: "이 회원의 역할을 변경할 권한이 없어요.")
                return
            }
            alert.addAction(UIAlertAction(title: "취소", style: .cancel))
            alert.popoverPresentationController?.sourceView = controller.view
            alert.popoverPresentationController?.sourceRect = CGRect(x: controller.view.bounds.midX, y: controller.view.bounds.midY, width: 1, height: 1)
            navigationController.topViewController?.present(alert, animated: true)
        }
        navigationController.pushViewController(controller, animated: true)
    }

    private func requestRoleReason(member: RoleMember, role: UserRole?, transfer: Bool, model: RoleManagementViewModel?) {
        let alert = UIAlertController(title: transfer ? "어드민 이전 사유" : "역할 변경 사유", message: "\(member.displayName) · \(member.roleTitle) → \(role?.title ?? "일반 회원")", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "변경 사유 (필수, 500자 이내)" }
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "다음", style: .default) { [weak self, weak model, weak alert] _ in
            let reason = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !reason.isEmpty, reason.count <= 500 else {
                self?.showAlert(title: "사유 확인", message: "변경 사유를 1~500자로 입력해 주세요.")
                return
            }
            let warning = transfer ? "\n이전 후 내 역할은 매니저로 바뀌고 매니저 임명과 어드민 이전 권한이 사라져요." : ""
            self?.confirm(title: transfer ? "어드민를 이전할까요?" : "역할을 변경할까요?", message: "\(member.displayName)\n\(member.id.uuidString)\n\(member.roleTitle) → \(role?.title ?? "일반 회원")\n사유: \(reason)\(warning)", actionTitle: transfer ? "어드민 이전" : "변경") {
                if transfer { model?.transfer(to: member, reason: reason) }
                else { model?.change(member, to: role, reason: reason) }
            }
        })
        navigationController.topViewController?.present(alert, animated: true)
    }

    private func showWallpapers() {
        let controller = WallpaperAdminListViewController(manage: container.makeManageWallpapersUseCase())
        controller.onEditSeries = { [weak self] series in self?.showSeriesEditor(series) }
        navigationController.pushViewController(controller, animated: true)
    }

    private func showSeriesEditor(_ series: WallpaperSeriesEntity?) {
        let controller = WallpaperSeriesEditorViewController(series: series, manage: container.makeManageWallpapersUseCase())
        controller.onWallpapers = { [weak self] selected in self?.showWallpaperItems(selected) }
        navigationController.pushViewController(controller, animated: true)
    }

    private func showWallpaperItems(_ series: WallpaperSeriesEntity) {
        let controller = WallpaperAdminItemsViewController(series: series, manage: container.makeManageWallpapersUseCase())
        controller.onEdit = { [weak self] wallpaper in self?.showWallpaperEditor(series: series, wallpaper: wallpaper) }
        navigationController.pushViewController(controller, animated: true)
    }

    private func showWallpaperEditor(series: WallpaperSeriesEntity, wallpaper: WallpaperEntity?) {
        navigationController.pushViewController(WallpaperItemEditorViewController(series: series, wallpaper: wallpaper, manage: container.makeManageWallpapersUseCase()), animated: true)
    }

    // MARK: - 목록 → 생성 / 수정 / 삭제 확인
    private func showList(_ category: AdminCategory, selectingEvent: Bool = false) {
        let viewModel = container.getAdminListViewModel(category: category)
        viewModel.onRoute = { [weak self, weak viewModel] route in
            guard let self else { return }
            switch route {
            case .create:
                switch category {
                case .feeds: showEditor(.newFeed)
                case .schedules: showList(.events, selectingEvent: true)
                case .events: showEditor(.newEvent)
                }
            case .edit(let item):
                switch item {
                case .feed(let feed): showEditor(.editFeed(feed))
                case .schedule(let schedule): showEditor(.editSchedule(schedule))
                case .event(let event):
                    showEditor(selectingEvent ? .newSchedule(event) : .editEvent(event))
                }
            case .confirmDelete(let item):
                let detail = deletionMessage(for: item)
                confirm(title: "‘\(item.title)’ 삭제", message: detail, actionTitle: "삭제") {
                    viewModel?.delete(item)
                }
            case .message(let title, let message):
                showAlert(title: title, message: message)
            }
        }
        if category == .feeds {
            navigationController.pushViewController(AdminFeedGridViewController(viewModel: viewModel), animated: true)
            return
        }
        let viewController = AdminListViewController(viewModel: viewModel, isSelectingEvent: selectingEvent)
        viewController.onManageEvents = { [weak self] in self?.showList(.events) }
        navigationController.pushViewController(viewController, animated: true)
    }

    private func deletionMessage(for item: AdminContent) -> String {
        switch item {
        case .feed: return "이 피드와 연결된 미디어가 모두 삭제됩니다. 되돌릴 수 없습니다."
        case .schedule: return "이 일정과 일정 전용 미디어가 삭제됩니다. 공통 행사와 다른 일정은 유지됩니다. 되돌릴 수 없습니다."
        case .event: return "이 행사와 연결된 모든 일정, 행사·일정 미디어가 함께 삭제됩니다. 되돌릴 수 없습니다."
        }
    }

    // MARK: - 편집기에서 직접 Alert나 다음 화면을 생성하지 않는다.
    private func showEditor(_ mode: AdminEditorMode) {
        let viewModel = container.getAdminEditorViewModel(mode: mode)
        let viewController = AdminEditorViewController(viewModel: viewModel)
        viewController.hidesBottomBarWhenPushed = true
        viewController.onPreview = { [weak viewController] items, index in
            let viewer = FeedDetailBottomSheetViewController(title: "미디어 미리보기", mediaItems: items, initialIndex: index)
            viewer.modalPresentationStyle = .pageSheet
            if let sheet = viewer.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
            }
            viewController?.present(viewer, animated: true)
        }
        viewController.onClose = { [weak self, weak viewModel] hasChanges in
            guard let self else { return }
            if hasChanges {
                confirm(title: "작성을 그만둘까요?", message: "저장하지 않은 입력 내용은 사라져요.", actionTitle: "나가기") { [weak self] in
                    viewModel?.endEditing()
                    self?.navigationController.popViewController(animated: true)
                }
            } else {
                viewModel?.endEditing()
                navigationController.popViewController(animated: true)
            }
        }
        viewController.onMessage = { [weak self] message in
            self?.showAlert(title: "파일 선택", message: message)
        }
        viewModel.onRoute = { [weak self, weak viewModel] route in
            guard let self else { return }
            navigationController.tabBarController?.tabBar.isUserInteractionEnabled = true
            switch route {
            case .confirmDelete(let item):
                confirm(title: "‘\(item.title)’ 전체 삭제", message: deletionMessage(for: item), actionTitle: "전체 삭제") { [weak viewModel] in
                    viewModel?.delete()
                }
            case .deleted(let queued):
                navigationController.popViewController(animated: true)
                let message = queued ? "항목을 삭제했어요. 연결된 R2 파일은 자동 정리 작업에서 삭제됩니다." : "항목을 삭제했어요."
                if let transition = navigationController.transitionCoordinator {
                    transition.animate(alongsideTransition: nil) { [weak self] _ in
                        self?.showAlert(title: "삭제 완료", message: message)
                    }
                } else {
                    showAlert(title: "삭제 완료", message: message)
                }
            case .saved:
                navigationController.popViewController(animated: true)
                // 화면 전환이 끝난 다음 안내해 Alert가 전환 중에 누락되지 않게 합니다.
                if let transition = navigationController.transitionCoordinator {
                    transition.animate(alongsideTransition: nil) { [weak self] _ in
                        self?.showAlert(title: "저장 완료", message: "변경 사항을 저장했어요.")
                    }
                } else {
                    showAlert(title: "저장 완료", message: "변경 사항을 저장했어요.")
                }
            case .failed(let message):
                showAlert(title: "작업을 완료하지 못했어요", message: message)
            case .accessDenied(let message):
                viewModel?.endEditing()
                showAlert(title: "권한 확인", message: message) { [weak self] in
                    self?.navigationController.popToRootViewController(animated: true)
                }
            case .editEvent(let event):
                showEditor(.editEvent(event))
            }
        }
        navigationController.pushViewController(viewController, animated: true)
    }

    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in completion?() })
        navigationController.topViewController?.present(alert, animated: true)
    }

    private func confirm(title: String, message: String, actionTitle: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: actionTitle, style: .destructive) { _ in completion() })
        navigationController.topViewController?.present(alert, animated: true)
    }
}

//
//  AuthorizationLayoutTests.swift
//  flover9Tests
//
//  Created by 박선린 on 9/29/26.
//

import UIKit
import XCTest
@testable import flover9

// 실제 관리 목록에서 회원 이름·역할·식별자가 표시되는지 확인합니다.
@MainActor final class AuthorizationLayoutTests: XCTestCase {
    func testRoleManagementLayout() async throws {
        let repository = AuthorizationRepositoryStub()
        repository.access = .init(userID: UUID(), role: .admin, permissions: [.rolesRead,.rolesManageCreator,.rolesManageManager,.rolesTransferAdmin])
        repository.membersResult = [
            .init(id: UUID(),nickname: "운영 어드민",role: .admin),
            .init(id: UUID(),nickname: "플로버 관리자",role: .manager),
            .init(id: UUID(),nickname: "배경화면 크리에이터",role: .creator),
            .init(id: UUID(),nickname: "일반 회원",role: nil)
        ]
        let model = RoleManagementViewModel(useCase: AuthorizationUseCase(repository: repository))
        let controller = RoleManagementViewController(viewModel: model)
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        let window = UIWindow(windowScene: scene)
        window.frame = CGRect(x: 0,y: 0,width: 393,height: 852)
        window.windowLevel = .alert + 1
        let navigation = UINavigationController(rootViewController: controller)
        AdminStyle.configureNavigationBar(navigation.navigationBar)
        window.rootViewController = navigation
        window.makeKeyAndVisible()
        controller.loadViewIfNeeded()
        let loaded = expectation(description: "Role list")
        let render = model.onChange
        model.onChange = { render?(); if !model.isLoading { loaded.fulfill() } }
        model.load()
        await fulfillment(of: [loaded], timeout: 3)
        model.onChange = render
        window.layoutIfNeeded()
        for (name, style) in [("light", UIUserInterfaceStyle.light), ("dark", .dark)] {
            window.overrideUserInterfaceStyle = style
            window.layoutIfNeeded()
            try await Task.sleep(for: .milliseconds(600))
            window.layoutIfNeeded()
            XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0),4)
            XCTAssertEqual(controller.tableView.visibleCells.count,4)
            XCTAssertTrue(controller.tableView.visibleCells.allSatisfy { $0.bounds.height > 40 })
            let image = UIGraphicsImageRenderer(bounds: window.bounds).image { _ in
                window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
            }
            let attachment = XCTAttachment(image: image)
            attachment.name = "회원 권한 관리 \(name)"
            attachment.lifetime = .keepAlways
            add(attachment)
            let path = FileManager.default.temporaryDirectory.appendingPathComponent("authorization-members-\(name).png")
            try image.pngData()?.write(to: path)
            print("AUTHORIZATION_SCREENSHOT=\(path.path)")
        }
        window.isHidden = true
    }
}

//
//  AdminDashboardViewController.swift
//  flover9
//
//  Created by 박선린 on 9/24/26.
//

import UIKit
import SnapKit

final class AdminDashboardViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: AdminDashboardViewModel

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let statusLabel = AdminStyle.label("권한을 확인하고 있어요", style: .body, color: .secondaryLabel)
    private let spinner = UIActivityIndicatorView(style: .medium)
    private let retryButton = AdminStyle.button("권한 다시 확인", symbol: "arrow.clockwise", primary: false)
    private let cards = UIStackView()
    private let identityLabel = AdminStyle.label("", style: .subheadline, color: .secondaryLabel)

    init(viewModel: AdminDashboardViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "관리자"
        configureLayout()
        bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        viewModel.checkAccess()
    }

    private func configureLayout() {
        view.backgroundColor = .systemGroupedBackground
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        stackView.axis = .vertical
        stackView.spacing = 20

        scrollView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
        stackView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide).inset(20)
            $0.width.equalTo(scrollView.frameLayoutGuide).offset(-40)
        }

        let eyebrow = AdminStyle.label("FLOVER 9  /  MANAGEMENT", style: .caption1, color: AdminStyle.accent)
        let heading = AdminStyle.label("좋은 소식을\n정확하게 전해요.", style: .largeTitle)
        stackView.addArrangedSubview(eyebrow)
        stackView.addArrangedSubview(heading)
        stackView.addArrangedSubview(identityLabel)
        stackView.addArrangedSubview(spinner)
        stackView.addArrangedSubview(statusLabel)
        stackView.addArrangedSubview(retryButton)

        cards.axis = .vertical
        cards.spacing = 16
        cards.addArrangedSubview(makeCard(
            title: "피드 관리",
            detail: "새로운 사진과 영상, 멤버들의 이야기를 관리해요.",
            symbol: "photo.stack",
            category: .feeds
        ))
        cards.addArrangedSubview(makeCard(
            title: "일정 관리",
            detail: "공통 행사 정보와 날짜별 일정을 구분해서 관리해요.",
            symbol: "calendar.badge.clock",
            category: .schedules
        ))
        stackView.addArrangedSubview(cards)
        stackView.addArrangedSubview(AdminStyle.label(
            "운영 안내\n저장한 내용은 서비스에 바로 반영돼요. 삭제 전에는 대상 항목을 한 번 더 확인해 주세요.",
            style: .footnote,
            color: .secondaryLabel
        ))
        retryButton.addAction(UIAction { [weak self] _ in
            self?.viewModel.checkAccess()
        }, for: .touchUpInside)
    }

    private func makeCard(title: String, detail: String, symbol: String, category: AdminCategory) -> UIButton {
        var configuration = UIButton.Configuration.filled()
        configuration.title = title
        configuration.subtitle = detail
        configuration.titleAlignment = .leading
        configuration.image = UIImage(systemName: symbol)
        configuration.imagePlacement = .top
        configuration.imagePadding = 18
        configuration.titlePadding = 8
        configuration.baseBackgroundColor = .secondarySystemGroupedBackground
        configuration.baseForegroundColor = .label
        configuration.cornerStyle = .large
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 24, leading: 24, bottom: 24, trailing: 24)
        let button = UIButton(configuration: configuration)
        button.contentHorizontalAlignment = .leading
        button.accessibilityHint = "검색, 생성, 수정 및 삭제"
        button.addAction(UIAction { [weak self] _ in
            self?.viewModel.open(category)
        }, for: .touchUpInside)
        return button
    }

    private func bind() {
        viewModel.onState = { [weak self] state in
            guard let self else { return }
            cards.isHidden = true
            identityLabel.isHidden = true
            retryButton.isHidden = true
            spinner.stopAnimating()
            statusLabel.isHidden = false

            switch state {
            case .checking:
                statusLabel.text = "로그인 정보와 관리 권한을 확인하고 있어요."
                spinner.startAnimating()
            case .ready(let profile):
                identityLabel.text = "\(profile.nickname ?? "운영자") · \(profile.role == .admin ? "관리자" : "매니저")"
                identityLabel.isHidden = false
                statusLabel.isHidden = true
                cards.isHidden = false
            case .unavailable(let message):
                statusLabel.text = message
                retryButton.isHidden = false
            }
        }
    }
}

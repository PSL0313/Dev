//
//  MemberProfileViewViewController.swift
//  flover9
//
//  Created by 박선린 on 8/14/26.
//

import UIKit
import SnapKit

final class MemberProfileViewViewController: UIViewController {
    
    private enum SupplementaryKind {
        static let profileHeader = "profile-header"
        static let statusFooter = "status-footer"
    }

    // MARK: - Properties
    private let viewModel: MemberProfileViewModel

    // MARK: - UI
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    private let refreshControl = UIRefreshControl()
    private let errorLabel = UILabel()

    
    // MARK: - Initializer
    init(viewModel: MemberProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - deinit
    deinit { print("deinit: \(Self.self)") }

    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureHierarchy()
        configureLayout()
        configureCollectionView()
        applySnapshot()
        loadIfNeeded()
    }

    private func configureView() {
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never

        errorLabel.font = .systemFont(ofSize: 13, weight: .medium)
        errorLabel.textColor = .label
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
    }

    private func configureHierarchy() {
        view.addSubview(collectionView)
        view.addSubview(errorLabel)
    }

    private func configureLayout() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            errorLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
        ])
    }

    private func configureCollectionView() {
        collectionView.backgroundColor = .systemBackground
        collectionView.alwaysBounceVertical = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(FeedGridCell.self, forCellWithReuseIdentifier: FeedGridCell.reuseIdentifier)
        collectionView.register(
            FeedProfileHeaderView.self,
            forSupplementaryViewOfKind: SupplementaryKind.profileHeader,
            withReuseIdentifier: FeedProfileHeaderView.reuseIdentifier
        )
        collectionView.register(
            FeedStatusFooterView.self,
            forSupplementaryViewOfKind: SupplementaryKind.statusFooter,
            withReuseIdentifier: FeedStatusFooterView.reuseIdentifier
        )
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }

    private func createLayout() -> UICollectionViewLayout {
            UICollectionViewCompositionalLayout { [weak self] _, _ in
                self?.makeSectionLayout()
            }
    }

    private func makeSectionLayout() -> NSCollectionLayoutSection {
        let spacing: CGFloat = 1
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / 3.0),
            heightDimension: .fractionalWidth(0.45)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: spacing, trailing: spacing)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(0.45)
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: Array(repeating: item, count: 3)
        )

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)

        let profileHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(190)
            ),
            elementKind: SupplementaryKind.profileHeader,
            alignment: .top
        )


        let footer = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(56)
            ),
            elementKind: SupplementaryKind.statusFooter,
            alignment: .bottom
        )

        // 멤버 아이디가 없는 경우(전체멤버) 상단 헤더 X
        if viewModel.memberId == nil {
            section.boundarySupplementaryItems = [footer]
            return section
        }

        section.boundarySupplementaryItems = [profileHeader, footer]
        return section
    }

    private func loadIfNeeded() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            await viewModel.loadIfNeeded()
            refreshControl.endRefreshing()
            applySnapshot()
        }
    }

    @objc
    private func handleRefresh() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            await viewModel.reload()
            refreshControl.endRefreshing()
            applySnapshot()
        }
    }

    private func applySnapshot() {
        title = viewModel.title
        collectionView.reloadData()

        if let errorMessage = viewModel.errorMessage, viewModel.feeds.isEmpty {
            errorLabel.text = errorMessage
            errorLabel.isHidden = false
        } else {
            errorLabel.isHidden = true
        }
    }

    private func loadMoreIfNeeded() {
        guard viewModel.canTriggerLoadMore else { return }

        Task { @MainActor [weak self] in
            guard let self else { return }
            guard viewModel.beginLoadMoreIfNeeded() else { return }
            applySnapshot()
            await viewModel.performLoadMore()
            applySnapshot()
        }
    }
}

extension MemberProfileViewViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.itemCount
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FeedGridCell.reuseIdentifier,
            for: indexPath
        ) as? FeedGridCell else {
            return UICollectionViewCell()
        }

        if let feed = viewModel.feed(at: indexPath.item) {
            cell.configure(with: feed)
        }
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        switch kind {
        case SupplementaryKind.profileHeader:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: FeedProfileHeaderView.reuseIdentifier,
                for: indexPath
            ) as? FeedProfileHeaderView else {
                return UICollectionReusableView()
            }
            headerView.configure(with: viewModel)
            return headerView

        case SupplementaryKind.statusFooter:
            guard let footerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: FeedStatusFooterView.reuseIdentifier,
                for: indexPath
            ) as? FeedStatusFooterView else {
                return UICollectionReusableView()
            }
            footerView.configure(with: viewModel)
            return footerView

        default:
            return UICollectionReusableView()
        }
    }
}

extension MemberProfileViewViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let feed = viewModel.feed(at: indexPath.item) else { return }
        
        let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: .now) ?? .now
        let isLockedFrommFeed = feed.source.lowercased() == "fromm"
            && feed.captureDate >= oneYearAgo
        guard !isLockedFrommFeed else { return }

        viewModel.action(.moveToFeedDetail(feed))
    }
    
    // 스크롤시 남은 높이가 240보다 작으면 피드 추가 요청
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !viewModel.hasReachedEndOfFeeds else { return }

        let remaining = scrollView.contentSize.height - scrollView.contentOffset.y - scrollView.bounds.height
        if remaining < 30 {
            loadMoreIfNeeded()
        }
    }

}

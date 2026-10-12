//
//  WallpaperHomeViewController.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Kingfisher
import SnapKit
import UIKit

// 히어로·카테고리와 추천·최신 시리즈 화면을 구성하고 사용자 동작을 연결합니다.
final class WallpaperHomeViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    private let viewModel: WallpaperHomeViewModel
    var onSeries: ((WallpaperSeriesEntity) -> Void)?
    var onSearch: (() -> Void)?
    var onAllSeries: ((WallpaperCategory?) -> Void)?
    private let status = WallpaperStatusView()
    init(viewModel: WallpaperHomeViewModel) {
        self.viewModel = viewModel
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        super.init(collectionViewLayout: layout)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.backgroundColor = .black
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset.bottom = tabBarController?.tabBar.bounds.height ?? 0
        collectionView.register(WallpaperCardCell.self, forCellWithReuseIdentifier: WallpaperCardCell.reuseID)
        collectionView.register(
            WallpaperHomeHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "hero")
        collectionView.register(
            WallpaperSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "section")
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "magnifyingglass"),
            primaryAction: UIAction { [weak self] _ in self?.onSearch?() })
        navigationItem.rightBarButtonItem?.accessibilityLabel = "배경화면 검색"
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addAction(
            UIAction { [weak self] _ in self?.viewModel.load(category: self?.viewModel.category) }, for: .valueChanged)
        view.addSubview(status)
        status.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.snp.top).offset(WallpaperLayout.imageHeight(for: view.bounds.width) + 44)
            $0.height.equalTo(150)
        }
        status.onRetry = { [weak self] in self?.viewModel.load(category: self?.viewModel.category) }
        viewModel.onChange = { [weak self] in self?.render() }
        viewModel.load()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    private var hasFeatured: Bool { !viewModel.featured.isEmpty }
    private func rows(_ section: Int) -> [WallpaperSeriesEntity] {
        if section == 0 {
            return Array(
                (hasFeatured ? viewModel.featured : viewModel.series).prefix(collectionView.bounds.width > 650 ? 3 : 2))
        }
        return Array(viewModel.series.prefix(6))
    }
    private func render() {
        collectionView.reloadData()
        if !viewModel.isLoading { collectionView.refreshControl?.endRefreshing() }
        status.update(
            loading: viewModel.isLoading && viewModel.series.isEmpty, error: viewModel.error,
            empty: viewModel.series.isEmpty && viewModel.featured.isEmpty, emptyMessage: "새로운 배경화면을 준비하고 있어요.")
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        status.snp.updateConstraints {
            $0.top.equalTo(view.snp.top).offset(WallpaperLayout.imageHeight(for: view.bounds.width) + 44)
        }
    }
    override func numberOfSections(in collectionView: UICollectionView) -> Int { hasFeatured ? 2 : 1 }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        rows(section).count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell
    {
        let cell =
            collectionView.dequeueReusableCell(withReuseIdentifier: WallpaperCardCell.reuseID, for: indexPath)
            as! WallpaperCardCell
        cell.configure(series: rows(indexPath.section)[indexPath.item])
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onSeries?(rows(indexPath.section)[indexPath.item])
    }
    override func collectionView(
        _ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if indexPath.section == 0 {
            let header =
                collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind, withReuseIdentifier: "hero", for: indexPath) as! WallpaperHomeHeader
            header.configure(
                series: viewModel.featured.first ?? viewModel.series.first, category: viewModel.category,
                featuredEmpty: !hasFeatured)
            header.categories.onSelect = { [weak self] in self?.viewModel.load(category: $0) }
            header.onMore = { [weak self] in self?.onAllSeries?(self?.viewModel.category) }
            return header
        }
        let header =
            collectionView.dequeueReusableSupplementaryView(
                ofKind: kind, withReuseIdentifier: "section", for: indexPath) as! WallpaperSectionHeader
        header.titleLabel.text = "최근 업데이트"
        header.onMore = { [weak self] in self?.onAllSeries?(self?.viewModel.category) }
        return header
    }
    func collectionView(
        _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let columns: CGFloat = collectionView.bounds.width > 650 ? 3 : 2
        let width = (collectionView.bounds.width - 36 - (columns - 1) * 12) / columns
        return .init(width: width, height: WallpaperLayout.imageHeight(for: width))
    }
    func collectionView(
        _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets { .init(top: 8, left: 18, bottom: 22, right: 18) }
    func collectionView(
        _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize { .init(width: collectionView.bounds.width, height: section == 0 ? WallpaperLayout.imageHeight(for: collectionView.bounds.width) + 44 : 44) }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

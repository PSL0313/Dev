//
//  WallpaperSeriesListViewController.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Kingfisher
import SnapKit
import UIKit

// 카테고리별 시리즈 목록 화면을 구성하고 사용자 동작을 연결합니다.
final class WallpaperSeriesListViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    private let viewModel: WallpaperSeriesListViewModel
    private let status = WallpaperStatusView()
    var onSeries: ((WallpaperSeriesEntity) -> Void)?
    var onSearch: (() -> Void)?
    private var initialCategory: WallpaperCategory?
    init(viewModel: WallpaperSeriesListViewModel, category: WallpaperCategory? = nil) {
        self.viewModel = viewModel
        initialCategory = category
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.sectionInset = .init(top: 12, left: 16, bottom: 20, right: 16)
        super.init(collectionViewLayout: layout)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "시리즈"
        overrideUserInterfaceStyle = .dark
        collectionView.backgroundColor = .black
        collectionView.register(WallpaperCardCell.self, forCellWithReuseIdentifier: WallpaperCardCell.reuseID)
        collectionView.register(
            WallpaperCategoryHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "category")
        collectionView.backgroundView = status
        status.onRetry = { [weak self] in self?.viewModel.loadMore() }
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "magnifyingglass"),
            primaryAction: UIAction { [weak self] _ in self?.onSearch?() })
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addAction(
            UIAction { [weak self] _ in self?.viewModel.reload(category: self?.viewModel.category) }, for: .valueChanged
        )
        viewModel.onChange = { [weak self] in
            guard let self else { return }
            collectionView.reloadData()
            if !viewModel.isLoading { collectionView.refreshControl?.endRefreshing() }
            status.update(
                loading: viewModel.isLoading && viewModel.items.isEmpty, error: viewModel.error,
                empty: viewModel.items.isEmpty, emptyMessage: "이 카테고리의 시리즈가 아직 없어요.")
        }
        viewModel.reload(category: initialCategory)
    }
    func selectCategory(_ category: WallpaperCategory?) {
        loadViewIfNeeded()
        viewModel.reload(category: category)
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.items.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell
    {
        let cell =
            collectionView.dequeueReusableCell(withReuseIdentifier: WallpaperCardCell.reuseID, for: indexPath)
            as! WallpaperCardCell
        cell.configure(series: viewModel.items[indexPath.item])
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onSeries?(viewModel.items[indexPath.item])
    }
    override func collectionView(
        _ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath
    ) { if indexPath.item >= viewModel.items.count - 4 { viewModel.loadMore() } }
    override func collectionView(
        _ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath
    ) -> UICollectionReusableView {
        let header =
            collectionView.dequeueReusableSupplementaryView(
                ofKind: kind, withReuseIdentifier: "category", for: indexPath) as! WallpaperCategoryHeader
        header.control.select(viewModel.category)
        header.control.onSelect = { [weak self] in self?.viewModel.reload(category: $0) }
        return header
    }
    func collectionView(
        _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize { .init(width: collectionView.bounds.width, height: 54) }
    func collectionView(
        _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let columns: CGFloat = collectionView.bounds.width > 650 ? 3 : 2
        let width = (collectionView.bounds.width - 32 - (columns - 1) * 12) / columns
        return .init(width: width, height: WallpaperLayout.imageHeight(for: width))
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

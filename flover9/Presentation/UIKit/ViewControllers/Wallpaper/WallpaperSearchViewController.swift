//
//  WallpaperSearchViewController.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import UIKit

// 검색어와 필터를 적용한 개별 배경화면 검색 화면을 구성하고 사용자 동작을 연결합니다.
final class WallpaperSearchViewController: UICollectionViewController, UISearchResultsUpdating,
    UICollectionViewDelegateFlowLayout
{
    private let viewModel: WallpaperSearchViewModel
    private let search = UISearchController(searchResultsController: nil)
    private let status = WallpaperStatusView()
    var onWallpaper: (([WallpaperEntity], Int) -> Void)?
    init(viewModel: WallpaperSearchViewModel) {
        self.viewModel = viewModel
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = .init(top: 16, left: 16, bottom: 24, right: 16)
        super.init(collectionViewLayout: layout)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "배경화면 검색"
        overrideUserInterfaceStyle = .dark
        collectionView.backgroundColor = .black
        collectionView.register(WallpaperCardCell.self, forCellWithReuseIdentifier: WallpaperCardCell.reuseID)
        search.searchResultsUpdater = self
        search.searchBar.placeholder = "배경화면 또는 시리즈 제목"
        search.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = search
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "필터", primaryAction: UIAction { [weak self] _ in self?.showFilters() })
        collectionView.keyboardDismissMode = .onDrag
        collectionView.backgroundView = status
        status.onRetry = { [weak self] in self?.viewModel.loadMore() }
        viewModel.onChange = { [weak self] in
            guard let self else { return }
            collectionView.reloadData()
            status.update(
                loading: viewModel.isLoading && viewModel.results.isEmpty, error: viewModel.error,
                empty: viewModel.results.isEmpty, emptyMessage: "검색 결과가 없어요.\n다른 제목이나 필터로 찾아보세요.")
            navigationItem.rightBarButtonItem?.title =
                viewModel.filter.activeCount == 0 ? "필터" : "필터 \(viewModel.filter.activeCount)"
        }
        viewModel.load()
    }
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text ?? ""
        guard viewModel.filter.query != text else { return }
        viewModel.filter.query = text
        viewModel.load(debounce: true)
    }
    private func showFilters() {
        navigationItem.rightBarButtonItem?.isEnabled = false
        Task {
            defer { navigationItem.rightBarButtonItem?.isEnabled = true }
            do {
                try await viewModel.loadOptions()
                let filter = WallpaperFilterViewController(filter: viewModel.filter, options: viewModel.options)
                filter.onApply = { [weak self] filter in
                    self?.viewModel.filter = filter
                    self?.viewModel.load()
                }
                let navigation = UINavigationController(rootViewController: filter)
                WallpaperStyle.navigation(navigation)
                present(navigation, animated: true)
            } catch { wallpaperAlert("필터를 불러오지 못했어요. \(error.localizedDescription)") }
        }
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.results.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell
    {
        let cell =
            collectionView.dequeueReusableCell(withReuseIdentifier: WallpaperCardCell.reuseID, for: indexPath)
            as! WallpaperCardCell
        cell.configure(wallpaper: viewModel.results[indexPath.item], caption: true)
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onWallpaper?(viewModel.results, indexPath.item)
    }
    override func collectionView(
        _ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath
    ) { if indexPath.item >= viewModel.results.count - 4 { viewModel.loadMore() } }
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

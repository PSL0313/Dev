//
//  WallpaperSeriesDetailViewController.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Kingfisher
import SnapKit
import UIKit

// 시리즈 설명·제작자 정보와 소속 배경화면 그리드 화면을 구성하고 사용자 동작을 연결합니다.
final class WallpaperSeriesDetailViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    private let viewModel: WallpaperDetailViewModel
    private let status = WallpaperStatusView()
    private var compact = true
    var onWallpaper: (([WallpaperEntity], Int) -> Void)?
    init(series: WallpaperSeriesEntity, browse: BrowseWallpapersUseCase) {
        viewModel = WallpaperDetailViewModel(series: series, browse: browse)
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        super.init(collectionViewLayout: layout)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.contentInsetAdjustmentBehavior = .never
        overrideUserInterfaceStyle = .dark
        collectionView.backgroundColor = .black
        collectionView.register(WallpaperCardCell.self, forCellWithReuseIdentifier: WallpaperCardCell.reuseID)
        collectionView.register(
            WallpaperDetailHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "detail")
        view.addSubview(status)
        status.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.snp.top).offset(WallpaperLayout.imageHeight(for: view.bounds.width) + 44)
            $0.height.equalTo(130)
        }
        status.onRetry = { [weak self] in self?.viewModel.load() }
        viewModel.onChange = { [weak self] in
            guard let self else { return }
            collectionView.reloadData()
            status.update(loading: viewModel.isLoading, error: viewModel.error, empty: viewModel.items.isEmpty)
        }
        viewModel.load()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        status.snp.updateConstraints {
            $0.top.equalTo(view.snp.top).offset(WallpaperLayout.imageHeight(for: view.bounds.width) + 44)
        }
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
        cell.configure(wallpaper: viewModel.items[indexPath.item], caption: !compact)
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onWallpaper?(viewModel.items, indexPath.item)
    }
    override func collectionView(
        _ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath
    ) -> UICollectionReusableView {
        let header =
            collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "detail", for: indexPath)
            as! WallpaperDetailHeader
        header.configure(viewModel.series, count: viewModel.items.count, compact: compact)
        header.onLayout = { [weak self] compact in
            self?.compact = compact
            self?.collectionView.reloadData()
            self?.collectionView.collectionViewLayout.invalidateLayout()
        }
        return header
    }
    func collectionView(
        _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        let description = viewModel.series.description as NSString
        let height = description.boundingRect(
            with: .init(width: collectionView.bounds.width - 36, height: 1000),
            options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font: UIFont.systemFont(ofSize: 14)],
            context: nil
        ).height
        return .init(width: collectionView.bounds.width, height: WallpaperLayout.imageHeight(for: collectionView.bounds.width) + 110 + ceil(height))
    }
    func collectionView(
        _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets { .init(top: 8, left: 16, bottom: 24, right: 16) }
    func collectionView(
        _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let columns: CGFloat = compact ? (collectionView.bounds.width > 650 ? 5 : 3) : 2
        let width = (collectionView.bounds.width - 32 - (columns - 1) * 8) / columns
        return .init(width: width, height: WallpaperLayout.imageHeight(for: width))
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

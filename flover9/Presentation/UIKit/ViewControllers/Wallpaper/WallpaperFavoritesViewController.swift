//
//  WallpaperFavoritesViewController.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import UIKit

// 기기에 저장된 즐겨찾기 배경화면 목록 화면을 구성하고 사용자 동작을 연결합니다.
final class WallpaperFavoritesViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    private let store: WallpaperFavoritesStore
    private var items: [WallpaperEntity] = []
    private let status = WallpaperStatusView()
    var onWallpaper: (([WallpaperEntity], Int) -> Void)?
    init(store: WallpaperFavoritesStore) {
        self.store = store
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = .init(top: 12, left: 16, bottom: 20, right: 16)
        super.init(collectionViewLayout: layout)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "즐겨찾기"
        collectionView.backgroundColor = .black
        collectionView.register(WallpaperCardCell.self, forCellWithReuseIdentifier: WallpaperCardCell.reuseID)
        collectionView.backgroundView = status
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        items = store.items
        collectionView.reloadData()
        status.update(loading: false, error: nil, empty: items.isEmpty, emptyMessage: "마음에 드는 배경화면의 하트를 눌러 보세요.")
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell
    {
        let cell =
            collectionView.dequeueReusableCell(withReuseIdentifier: WallpaperCardCell.reuseID, for: indexPath)
            as! WallpaperCardCell
        cell.configure(wallpaper: items[indexPath.item], caption: true)
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onWallpaper?(items, indexPath.item)
    }
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

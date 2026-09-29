//
//  WallpaperPreviewViewController.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import Kingfisher
import SnapKit
import UIKit

// 목업 확대 보기·원본 이미지 목록·즐겨찾기·다운로드 화면을 구성하고 사용자 동작을 연결합니다.
final class WallpaperPreviewViewController: UIViewController, UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout
{
    private let items: [WallpaperEntity]
    private var index: Int
    private let download: DownloadWallpaperUseCase
    private let favorites: WallpaperFavoritesStore
    private let pages: UICollectionView
    private let thumbnails: UICollectionView
    private let downloadButton = UIButton(configuration: .filled())
    private var task: Task<Void, Never>?
    private var exportURL: URL?
    private var positioned = false
    init(items: [WallpaperEntity], index: Int, download: DownloadWallpaperUseCase, favorites: WallpaperFavoritesStore) {
        self.items = items
        self.index = max(0, min(index, items.count - 1))
        self.download = download
        self.favorites = favorites
        let pageLayout = UICollectionViewFlowLayout()
        pageLayout.scrollDirection = .horizontal
        pageLayout.minimumLineSpacing = 0
        pages = UICollectionView(frame: .zero, collectionViewLayout: pageLayout)
        
        let thumbLayout = UICollectionViewFlowLayout()
        thumbLayout.scrollDirection = .horizontal
        thumbLayout.minimumLineSpacing = 8
        thumbLayout.sectionInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        thumbnails = UICollectionView(frame: .zero, collectionViewLayout: thumbLayout)
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        view.backgroundColor = .black
        for collection in [pages, thumbnails] {
            collection.backgroundColor = .black
            collection.dataSource = self
            collection.delegate = self
            collection.showsHorizontalScrollIndicator = false
            view.addSubview(collection)
        }
        pages.isPagingEnabled = true
        pages.register(WallpaperZoomCell.self, forCellWithReuseIdentifier: "page")
        thumbnails.register(WallpaperCardCell.self, forCellWithReuseIdentifier: WallpaperCardCell.reuseID)
        downloadButton.configuration?.title = "다운로드"
        downloadButton.configuration?.image = UIImage(systemName: "arrow.down.to.line")
        downloadButton.configuration?.imagePadding = 10
        downloadButton.configuration?.baseBackgroundColor = .white
        downloadButton.configuration?.baseForegroundColor = .black
        downloadButton.configuration?.cornerStyle = .capsule
        downloadButton.addAction(UIAction { [weak self] _ in self?.export() }, for: .touchUpInside)
        view.addSubview(downloadButton)
        downloadButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(18)
            $0.height.equalTo(52)
        }
        thumbnails.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(downloadButton.snp.top).offset(-20)
            $0.height.equalTo(78)
        }
        pages.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(thumbnails.snp.top).offset(-14)
        }
        updateTitle()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !positioned && !items.isEmpty && pages.bounds.width > 0 {
            pages.layoutIfNeeded()
            pages.scrollToItem(at: .init(item: index, section: 0), at: .centeredHorizontally, animated: false)
            positioned = true
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent { task?.cancel() }
    }
    
    /// 타이틀
    private func updateTitle() {
        title = items.isEmpty ? "배경화면" : "\(index + 1) / \(items.count)"
        downloadButton.isEnabled = !items.isEmpty && task == nil
        guard items.indices.contains(index) else { return }
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: favorites.contains(items[index].id) ? "heart.fill" : "heart"),
            primaryAction: UIAction { [weak self] _ in
                guard let self else { return }
                favorites.toggle(items[index])
                updateTitle()
            })
        navigationItem.rightBarButtonItem?.accessibilityLabel = "즐겨찾기 변경"
        thumbnails.reloadData()
        guard thumbnails.bounds.width > 0 else { return }
        thumbnails.scrollToItem(at: .init(item: index, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    /// numberOfItems
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { items.count }
    
    
    /// Cell 설정
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if collectionView === pages {
            let cell =
                collectionView.dequeueReusableCell(withReuseIdentifier: "page", for: indexPath) as! WallpaperZoomCell
            cell.configure(items[indexPath.item])
            return cell
        }
        let cell =
            collectionView.dequeueReusableCell(withReuseIdentifier: WallpaperCardCell.reuseID, for: indexPath)
            as! WallpaperCardCell
        cell.configure(wallpaper: items[indexPath.item], useOriginal: true)
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.borderWidth = indexPath.item == index ? 2 : 0
        cell.layer.cornerRadius = 10
        return cell
    }
    
    /// 선택한 셀이 thumbnails 컬렉션뷰가 아닌 경우(하단 컬렉션뷰인 경우) 해당 아이템으로 이동
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView === thumbnails else { return }
        index = indexPath.item
        pages.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        updateTitle()
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView === pages, pages.bounds.width > 0 else { return }
        index = min(items.count - 1, max(0, Int(round(pages.contentOffset.x / pages.bounds.width))))
        updateTitle()
    }
    
    func collectionView(
        _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize { collectionView === pages ? pages.bounds.size : .init(width: 45, height: 78) }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        positioned = false
        pages.collectionViewLayout.invalidateLayout()
    }
    private func export() {
        guard task == nil, items.indices.contains(index) else { return }
        let wallpaper = items[index]
        downloadButton.configuration?.showsActivityIndicator = true
        downloadButton.isEnabled = false
        task = Task { [weak self] in
            guard let self else { return }
            defer {
                task = nil
                downloadButton.configuration?.showsActivityIndicator = false
                downloadButton.isEnabled = true
            }
            do {
                let file = try await download.execute(wallpaper)
                if Task.isCancelled {
                    try? FileManager.default.removeItem(at: file)
                    return
                }
                if let old = exportURL { try? FileManager.default.removeItem(at: old) }
                exportURL = file
                let share = UIActivityViewController(activityItems: [file], applicationActivities: nil)
                share.popoverPresentationController?.sourceView = downloadButton
                share.popoverPresentationController?.sourceRect = downloadButton.bounds
                share.completionWithItemsHandler = { [weak self] _, _, _, _ in
                    try? FileManager.default.removeItem(at: file)
                    self?.exportURL = nil
                }
                present(share, animated: true)
            } catch is CancellationError {} catch { wallpaperAlert(error.localizedDescription, title: "다운로드 실패") }
        }
    }
    deinit {
        task?.cancel()
        if let exportURL { try? FileManager.default.removeItem(at: exportURL) }
    }
}

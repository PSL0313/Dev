//
//  FeedDetailBottomSheetViewController.swift
//  Flover9
//
//  Created by 박선린 on 5/14/26.
//

import UIKit

final class FeedDetailBottomSheetViewController: UIViewController {
    private let feed: FeedEntity
    private let mediaItems: [FeedImageEntity]
    private let initialIndex: Int
    private let pageControl = UIPageControl()
    private let countLabel = UILabel()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    private var hasAppliedInitialOffset = false

    init(feed: FeedEntity, mediaItems: [FeedImageEntity], initialIndex: Int = 0) {
        self.feed = feed
        self.mediaItems = mediaItems
        self.initialIndex = initialIndex
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureViewer()
        configureHierarchy()
        configureLayout()
        configureCollectionView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
        guard !hasAppliedInitialOffset, mediaItems.indices.contains(initialIndex) else { return }
        let offset = CGFloat(initialIndex) * collectionView.bounds.width
        collectionView.setContentOffset(CGPoint(x: offset, y: 0), animated: false)
        pageControl.currentPage = initialIndex
        hasAppliedInitialOffset = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        collectionView.visibleCells
            .compactMap { $0 as? FeedDetailImageCell }
            .forEach { $0.pauseVideo() }
    }

    private func configureViewer() {
        title = feed.title
        navigationItem.largeTitleDisplayMode = .never
        countLabel.font = .monospacedDigitSystemFont(ofSize: 13, weight: .semibold)
        countLabel.textColor = .secondaryLabel
        countLabel.textAlignment = .center
        pageControl.numberOfPages = mediaItems.count
        pageControl.currentPage = initialIndex
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.3)

        updatePageIndicators(index: initialIndex)
    }

    private func configureHierarchy() {
        view.addSubview(collectionView)
        view.addSubview(pageControl)
        view.addSubview(countLabel)
    }

    private func configureLayout() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: countLabel.topAnchor, constant: -6),

            countLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            countLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            countLabel.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -2),

            pageControl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageControl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            
        ])
    }

    private func configureCollectionView() {
        collectionView.backgroundColor = .systemBackground
        collectionView.isPagingEnabled = true
        collectionView.alwaysBounceHorizontal = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(FeedDetailImageCell.self, forCellWithReuseIdentifier: FeedDetailImageCell.reuseIdentifier)
    }

    private func updateCurrentPage(with scrollView: UIScrollView) {
        let width = max(scrollView.bounds.width, 1)
        let rawPage = Int(round(scrollView.contentOffset.x / width))
        updatePageIndicators(index: rawPage)
    }

    private func updatePageIndicators(index: Int) {
        let lastIndex = max(mediaItems.count - 1, 0)
        let safeIndex = min(max(index, 0), lastIndex)
        pageControl.currentPage = safeIndex
        countLabel.text = mediaItems.isEmpty ? "0 / 0" : "\(safeIndex + 1) / \(mediaItems.count)"
    }

    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        return layout
    }
}

extension FeedDetailBottomSheetViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        mediaItems.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FeedDetailImageCell.reuseIdentifier,
            for: indexPath
        ) as? FeedDetailImageCell else {
            return UICollectionViewCell()
        }

        cell.configure(media: mediaItems[indexPath.item])
        return cell
    }
}

extension FeedDetailBottomSheetViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        (cell as? FeedDetailImageCell)?.playIfVideo()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        (cell as? FeedDetailImageCell)?.pauseVideo()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCurrentPage(with: scrollView)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateCurrentPage(with: scrollView)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else { return }
        updateCurrentPage(with: scrollView)
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateCurrentPage(with: scrollView)
    }
}

extension FeedDetailBottomSheetViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        collectionView.bounds.size
    }
}

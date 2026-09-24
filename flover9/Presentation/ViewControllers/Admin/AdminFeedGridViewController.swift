import UIKit

// MARK: - 일반 피드와 같은 3열 썸네일 목록에서 수정할 피드를 선택
final class AdminFeedGridViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    private let viewModel: AdminListViewModel
    private let searchController = UISearchController(searchResultsController: nil)
    private let refreshControl = UIRefreshControl()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    init(viewModel: AdminListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "피드 관리"
        navigationItem.prompt = "피드를 눌러 수정 · 길게 눌러 삭제"
        view.backgroundColor = .systemBackground
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        collectionView.register(FeedGridCell.self, forCellWithReuseIdentifier: FeedGridCell.reuseIdentifier)
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 1
            layout.minimumLineSpacing = 1
        }
        searchController.searchBar.placeholder = "피드 제목 검색"
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .add, primaryAction: UIAction { [weak self] _ in
            self?.viewModel.create()
        })
        refreshControl.addAction(UIAction { [weak self] _ in self?.viewModel.reload() }, for: .valueChanged)
        collectionView.refreshControl = refreshControl
        viewModel.onChange = { [weak self] in self?.render() }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.reload()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    private func render() {
        if !viewModel.isLoading { refreshControl.endRefreshing() }
        collectionView.reloadData()
        if viewModel.items.isEmpty || viewModel.errorMessage != nil {
            var state = UIContentUnavailableConfiguration.empty()
            state.image = UIImage(systemName: "photo.stack")
            state.text = viewModel.isLoading ? "피드를 불러오고 있어요" : "피드를 확인해 주세요"
            state.secondaryText = viewModel.errorMessage ?? "오른쪽 위 + 버튼으로 첫 피드를 등록하세요."
            state.button.title = "다시 불러오기"
            state.buttonProperties.primaryAction = UIAction { [weak self] _ in self?.viewModel.reload() }
            contentUnavailableConfiguration = state
        } else {
            contentUnavailableConfiguration = nil
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        viewModel.reload(query: searchBar.text ?? "")
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) { viewModel.reload(query: "") }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { viewModel.items.count }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedGridCell.reuseIdentifier, for: indexPath) as! FeedGridCell
        if case .feed(let feed) = viewModel.items[indexPath.item] {
            cell.configure(with: feed, isManagement: true)
            cell.accessibilityLabel = "\(feed.title ?? "피드"), 수정하기"
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.select(indexPath.item)
    }

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(actionProvider: { [weak self] _ in
            UIMenu(children: [
                UIAction(title: "수정", image: UIImage(systemName: "pencil")) { _ in self?.viewModel.select(indexPath.item) },
                UIAction(title: "피드 삭제", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in self?.viewModel.requestDeletion(indexPath.item) }
            ])
        })
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item >= viewModel.items.count - 6 { viewModel.loadMore() }
    }

    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = floor((collectionView.bounds.width - 2) / 3)
        return CGSize(width: width, height: width * 4 / 3)
    }
}

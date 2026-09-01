//
//  HomeContainerViewController.swift
//  flover9
//
//  Created by 박선린 on 8/10/26.
//

import UIKit
import MusicKit

// MARK: - HomeViewController
class HomeViewController: UIViewController {

    // MARK: - UI
    // 홈 화면의 콘텐츠를 표시하는 컬렉션뷰
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,   // 처음 생성시 크기 X
            collectionViewLayout: createLayout()
        )

        collectionView.backgroundColor = .systemBackground          // 홈 화면 배경색
        collectionView.showsVerticalScrollIndicator = false         // 세로 스크롤바 숨김
        collectionView.isScrollEnabled = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.contentInsetAdjustmentBehavior = .never

        // 컬렉션뷰 섹션 헤더뷰등록
        collectionView.register(
            HomeTabSectionHeaderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: HomeTabSectionHeaderCollectionReusableView.identifier
        )

        collectionView.register(HomeHeroCell.self, forCellWithReuseIdentifier: HomeHeroCell.reuseIdentifier)

        // 멤버 리스트셀등록
        collectionView.register(
            MemberCollectionViewCell.self,
            forCellWithReuseIdentifier: MemberCollectionViewCell.reuseIdentifier
        )

        // 스케쥴 셀 등록
        collectionView.register(
            HomeScheduleCell.self,
            forCellWithReuseIdentifier: HomeScheduleCell.reuseIdentifier
        )

        // 앨범 셀 등록
        collectionView.register(
            MusicAlbumCollectionViewCell.self,
            forCellWithReuseIdentifier:
                MusicAlbumCollectionViewCell.reuseIdentifier
        )

        return collectionView
    }()

    // MARK: - Properties
    private let viewModel: HomeViewModel
    private let layoutFactory = HomeCollectionViewLayoutFactory()

    // MARK: - 홈 컬렉션뷰의 섹션과 아이템을 관리하는 데이터 소스
    private lazy var dataSource: UICollectionViewDiffableDataSource<HomeSection, HomeItem> = configureDataSource()

    // MARK: - Initializer
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - Deinit
    deinit { print("HomeViewController deinit") }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        // Layout
        setLayout()

        // CollectionView Setting
        collectionView.delegate = self

        // ViewModel Setting
        bindViewModel()
    }

    private func bindViewModel() {
        viewModel.onState = { [weak self] state in
            guard let self else { return }
            switch state {
            case .fetchedHomeData:
                applySnapshot()
            case .fetchedAlbumData:
                print("✅ fetchedAlbumData")
                print("albums:", viewModel.albums.count)
                print("others:", viewModel.others.count)
                applyAlbumSnapshot()
            }
        }
    }
}

// MARK: - Layout
private extension HomeViewController {
    // setLayout
    private func setLayout() {
        self.view.backgroundColor = .systemBackground

        self.view.addSubview(collectionView)
        self.navigationController?.navigationBar.isHidden = true

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // 탭배 하단에 안쪽으로 탭바 높이 두기
        collectionView.contentInset.bottom = tabBarController?.tabBar.bounds.height ?? 0
    }
}


// MARK: - CollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch item {
        case .member:
            break
        case .schedule(let schedule):
            viewModel.action(.moveToSchedule(schedule.id))

        case .albums(let album):
            let detailViewController = TestAlbumDetailViewController(
                album: album
            )
            navigationController?.pushViewController(
                detailViewController,
                animated: true
            )
            print("앨범 선택:", album.title)

        case .otherAlbums(let album):
            let detailViewController = TestAlbumDetailViewController(
                album: album
            )
            navigationController?.pushViewController(
                detailViewController,
                animated: true
            )
            print("앨범 선택:", album.title)

        }
    }
}

// MARK: - 컬렉션뷰
extension HomeViewController {

    // MARK: - 아이템 종류에 따라 사용할 셀을 결정
    private func configureDataSource() -> UICollectionViewDiffableDataSource<HomeSection, HomeItem> {
        // 데이터소스 설정
        dataSource =
        UICollectionViewDiffableDataSource<HomeSection, HomeItem>(collectionView: collectionView ) { collectionView, indexPath, item in

            switch item {
            case .member(let member):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier:
                        HomeHeroCell.reuseIdentifier,
                    for: indexPath
                ) as? HomeHeroCell else {
                    return UICollectionViewCell()
                }

                cell.configure(members: member) // 멤버 정보를 셀에 표시
                cell.didTapMember = { [weak self] member in
                    guard let self else { return }
                    self.viewModel.action(.moveToMember(member))
                }
                return cell

            case .schedule(let schedule):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier:
                        HomeScheduleCell.reuseIdentifier,
                    for: indexPath
                ) as? HomeScheduleCell else {
                    return UICollectionViewCell()
                }

                cell.configure(with: schedule) // 일정 정보를 셀에 표시
                return cell
            case .albums(let album), .otherAlbums(let album):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier:
                        MusicAlbumCollectionViewCell.reuseIdentifier,
                    for: indexPath
                ) as? MusicAlbumCollectionViewCell else {
                    return UICollectionViewCell()
                }

                cell.configure(with: album)
                return cell
            }
        }
        
        // 섹션별 헤더 설정
        dataSource.supplementaryViewProvider = {
            [weak self] collectionView, kind, indexPath in
            guard let self else { return nil }

            guard kind == UICollectionView.elementKindSectionHeader else {
                return nil
            }

            let sections = self.dataSource.snapshot().sectionIdentifiers

            guard sections.indices.contains(indexPath.section) else {
                return nil
            }

            let section = sections[indexPath.section]

            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: HomeTabSectionHeaderCollectionReusableView.identifier,
                for: indexPath
            ) as? HomeTabSectionHeaderCollectionReusableView else {
                return nil
            }
            switch section {
            case .members:
                header.configure(headerType: .member)
            case .schedules:
                header.configure(headerType: .upComingSchedule) { [weak self] in
                    guard let self else { return }
                    viewModel.action(.moveToAllSchedule)
                }
            case .albums:
                header.configure(headerType: .albums)

            case .otherAlbums:
                header.configure(headerType: .otherAlbums)

            }

            return header
        }
        
        return dataSource
    }

    // MARK: - 현재 홈 데이터를 컬렉션뷰에 반영
    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<
            HomeSection,
            HomeItem
        >()

        // 컬렉션뷰에 표시할 섹션을 순서대로 추가
        snapshot.appendSections([
            .members,
            .schedules,
            .albums,
            .otherAlbums
        ])
        
        snapshot.appendItems([
                .member(viewModel.members)
            ],
            toSection: .members
        )

        // 일정 데이터를 HomeItem으로 변환
        let scheduleItems = viewModel.homeSchedulesCardData.map {
            HomeItem.schedule($0)
        }

        // 일정 섹션에 일정 아이템 추가
        snapshot.appendItems(
            scheduleItems,
            toSection: .schedules
        )

        // 완성된 화면 상태를 데이터 소스에 전달
        dataSource.apply(
            snapshot,
            animatingDifferences: true
        )
    }

    private func applyAlbumSnapshot() {
        var snapshot = dataSource.snapshot()

        snapshot.deleteItems(
            snapshot.itemIdentifiers(inSection: .albums)
        )

        snapshot.deleteItems(
            snapshot.itemIdentifiers(inSection: .otherAlbums)
        )

        snapshot.appendItems(
            viewModel.albums.map { .albums($0) },
            toSection: .albums
        )

        snapshot.appendItems(
            viewModel.others.map { .otherAlbums($0) },
            toSection: .otherAlbums
        )

        UIView.animate(withDuration: 0.5, animations: {
            self.dataSource.apply(
                snapshot,
                animatingDifferences: true
            )
        })
    }
}


// MARK: - CollectionView Layout
private extension HomeViewController {

    func createLayout() -> UICollectionViewLayout {
        layoutFactory.makeLayout { [weak self] sectionIndex in
            guard let self else {
                return nil
            }

            let sections = dataSource.snapshot().sectionIdentifiers
            return sections.indices.contains(sectionIndex)
                ? sections[sectionIndex]
                : nil
        }
    }
}

extension HomeViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 스크롤이 최상단 이상으로 올라가지 못하도록 상단 바운스 제어
        collectionView.bounces = collectionView.contentOffset.y > 0
    }
}

// MARK: - 홈 컬렉션뷰에서 표시할 섹션 종류
nonisolated enum HomeSection: Int, CaseIterable {
    case members       // 멤버 목록 섹션
    case schedules     // 다가오는 일정 섹션
    case albums        // 앨범
    case otherAlbums   // OST등 프로미스나인 이외의 음원 활동
}

// MARK: - 홈 컬렉션뷰에서 표시할 아이템 종류
nonisolated private enum HomeItem: Hashable {
    case member([MemberEntity])               // 멤버 한 명
    case schedule(HomeScheduleCardModel)    // 일정 한 개
    case albums(Album)                             // 앨범
    case otherAlbums(Album)                        // OST등 프로미스나인 이외의 음원 활동
}

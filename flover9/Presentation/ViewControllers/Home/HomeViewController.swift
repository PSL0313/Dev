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

        // 컬렉션뷰 섹션 헤더뷰등록
        collectionView.register(
            HomeTabSectionHeaderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: HomeTabSectionHeaderCollectionReusableView.identifier
        )
        
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
    
    // MARK: - 홈 컬렉션뷰의 섹션과 아이템을 관리하는 데이터 소스
    private var dataSource: UICollectionViewDiffableDataSource<HomeSection, HomeItem>!
    
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
        configureDataSource()
        configureSectionHeader()
        
        // ViewModel Setting
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel.onState = { [weak self] state in
            guard let self else { return }
            switch state {
            case .fetchedHomeData:
                applySnapshot()
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
    }
}


// MARK: - CollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch item {
        case .member(let member):
            viewModel.action(.moveToMember(member))
            print("멤버 선택:", member.displayName)

        case .schedule(let schedule):
            viewModel.action(.moveToSchedule(schedule.id))
            print("일정 선택:", schedule.title)
            
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
    private func configureDataSource() {
        dataSource =
        UICollectionViewDiffableDataSource<HomeSection, HomeItem>(collectionView: collectionView ) { collectionView, indexPath, item in

            switch item {
            case .member(let member):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier:
                        MemberCollectionViewCell.reuseIdentifier,
                    for: indexPath
                ) as? MemberCollectionViewCell else {
                    return UICollectionViewCell()
                }

                cell.configure(with: member) // 멤버 정보를 셀에 표시
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
    }
    
    private func configureSectionHeader() {
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
            case .schedules:
                header.configure(upComingScheduleType: .upComingSchedule) { [weak self] in
                    guard let self else { return }
                    viewModel.action(.moveToAllSchedule)
                }
            case .albums:
                header.configure(upComingScheduleType: .albums) {}

            case .otherAlbums:
                header.configure(upComingScheduleType: .otherAlbums) {}

            case .members:
                header.configure(upComingScheduleType: .member) {}
            }
            
            return header
        }
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

        // 멤버 데이터를 HomeItem으로 변환
        let memberItems = viewModel.members.map { HomeItem.member($0) }

        // 멤버 섹션에 멤버 아이템 추가
        snapshot.appendItems(
            memberItems,
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
        
        // 앨범 데이터를 HomeItem으로 변환
        let albumItems = viewModel.albums.map {
            HomeItem.albums($0)
        }

        // 앨범 섹션에 앨범 아이템 추가
        snapshot.appendItems(
            albumItems,
            toSection: .albums
        )
        
        // 그룹 앨범이외의 앨범 데이터를 HomeItem으로 변환
        let otherAlbumItems = viewModel.others.map {
            HomeItem.otherAlbums($0)
        }

        // 그룹 앨범 이외의 앨범 섹션에 앨범 아이템 추가
        snapshot.appendItems(
            otherAlbumItems,
            toSection: .otherAlbums
        )

        // 완성된 화면 상태를 데이터 소스에 전달
        dataSource.apply(
            snapshot,
            animatingDifferences: true
        )
    }
    
}


// MARK: - CollectionView Layout
private extension HomeViewController {
    // MARK: - 홈 컬렉션뷰의 섹션별 레이아웃 생성
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout {
            [weak self] sectionIndex, _ in

            guard let self else {
                return nil
            }

            // 현재 snapshot에서 sectionIndex에 해당하는 섹션을 조회
            let sections = self.dataSource.snapshot().sectionIdentifiers

            guard sections.indices.contains(sectionIndex) else {
                return nil
            }

            let section = sections[sectionIndex]

            // 섹션 종류에 맞는 레이아웃 반환
            switch section {
            case .members:
                return self.makeMemberSection()
            case .schedules:
                return self.makeScheduleSection()
            case .albums:
                return self.makeAlbumSection()
            case .otherAlbums:
                return self.makeAlbumSection()
            }
        }
        return layout
        
    }
    
    // MARK: - 멤버 섹션의 크기와 배치 생성
    private func makeMemberSection() -> NSCollectionLayoutSection {

        /*
         NSCollectionLayoutSize
         - widthDimension: 가로 크기를 결정
         - heightDimension: 세로 크기를 결정

         사용할 수 있는 대표적인 크기 지정 방식

         1. .fractionalWidth(비율)
            부모 영역의 가로 크기를 기준으로 계산
            1.0 = 부모 너비의 100%
            0.5 = 부모 너비의 50%

         2. .fractionalHeight(비율)
            부모 영역의 세로 크기를 기준으로 계산
            1.0 = 부모 높이의 100%
            0.5 = 부모 높이의 50%

         3. .absolute(고정값)
            정확한 pt 단위로 고정
            예: .absolute(100) = 항상 100pt

         4. .estimated(예상값)
            우선 전달한 값을 사용한 다음,
            내부 콘텐츠와 Auto Layout을 기준으로 실제 크기를 조정
            예: .estimated(150)
         */
        let itemSize = NSCollectionLayoutSize(

            // Item이 속한 Group 너비의 1/5을 사용
            // 멤버 다섯 명을 한 줄에 배치하기 위한 너비
            widthDimension: .fractionalWidth(1.0 / 5.0),

            // Item이 속한 Group 높이의 100%를 사용
            heightDimension: .fractionalHeight(1.0)
        )

        /*
         NSCollectionLayoutItem
         - 컬렉션뷰 셀 한 개가 차지하는 레이아웃 공간을 의미
         - 여기서는 멤버 한 명을 표시하는 셀 한 개
         
         layoutSize:
         - 위에서 만든 itemSize를 셀의 크기로 사용
         */
        let item = NSCollectionLayoutItem(
            layoutSize: itemSize
        )

        /*
         contentInsets
         - Item이 할당받은 영역 안쪽에 여백을 추가
         - 셀 전체의 위치를 이동하는 것이 아니라
           셀이 실제로 표시되는 영역을 안쪽으로 줄임

         NSDirectionalEdgeInsets의 매개변수

         top:
         - 위쪽 안쪽 여백

         leading:
         - 글자 진행 방향의 시작 부분 여백
         - 한국어·영어처럼 왼쪽에서 오른쪽으로 읽는 환경에서는 왼쪽

         bottom:
         - 아래쪽 안쪽 여백

         trailing:
         - 글자 진행 방향의 끝부분 여백
         - 한국어·영어 환경에서는 오른쪽
         */
        item.contentInsets = NSDirectionalEdgeInsets(
            top: 3,       // 셀 위쪽 여백 없음
            leading: 3,   // 셀 왼쪽에 3pt 여백
            bottom: 3,    // 셀 아래쪽 여백 없음
            trailing: 3   // 셀 오른쪽에 3pt 여백
        )

        /*
         Group 전체의 크기 설정

         Group:
         - 여러 Item을 한 번에 배치하는 공간
         - 여기서는 멤버 셀 다섯 개를 담는 한 줄

         widthDimension: .fractionalWidth(1.0)
         - Section에서 사용할 수 있는 가로 공간의 100% 사용

         heightDimension: .estimated(150)
         - 그룹 높이를 우선 150pt로 예상
         - 셀 내부 Auto Layout과 콘텐츠에 따라 실제 높이가 조정될 수 있음
         */
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(90)
        )

        /*
         NSCollectionLayoutGroup.horizontal
         - Item을 가로 방향으로 배치하는 Group 생성

         layoutSize:
         - Group 전체의 크기
         - 위에서 만든 groupSize 사용

         repeatingSubitem:
         - 반복해서 배치할 Item
         - 여기서는 동일한 형태의 멤버 셀

         count:
         - 한 Group 안에 반복해서 배치할 Item 개수
         - 5이므로 한 줄에 멤버 셀 다섯 개 배치
         */
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            repeatingSubitem: item,
            count: 5
        )

        /*
         Group 배치 방향의 종류

         .horizontal(...)
         - Item을 왼쪽에서 오른쪽으로 배치
         - 현재 멤버 목록처럼 한 줄에 여러 셀을 표시할 때 사용

         .vertical(...)
         - Item을 위에서 아래로 배치
         - 여러 셀을 세로로 쌓을 때 사용

         .custom(...)
         - 각 Item의 위치와 크기를 직접 계산해야 하는
           특수한 형태의 레이아웃에서 사용
         */

        /*
         NSCollectionLayoutSection
         - 하나 이상의 Group을 반복해서 표시하는 화면 영역
         - 여기서는 멤버 목록 전체 영역

         group:
         - 이 Section에서 반복해서 사용할 Group
         - 데이터가 Group 하나의 수용량보다 많으면
           Collection View가 Group을 추가로 반복해서 배치
         */
        let section = NSCollectionLayoutSection(
            group: group
        )
        

        /*
         Section 전체의 안쪽 여백

         Item의 contentInsets와 차이:
         - item.contentInsets:
         개별 셀마다 적용되는 안쪽 여백
         
         - section.contentInsets:
         섹션 전체와 컬렉션뷰 가장자리 사이의 여백
         
         즉, 아래 값은 멤버 셀 각각이 아니라
         멤버 섹션 전체 바깥쪽에 적용됨
         */
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,       // 섹션 위쪽에 16pt
            leading: 16,   // 섹션 왼쪽에 16pt
            bottom: 16,    // 섹션 아래쪽에 16pt
            trailing: 16   // 섹션 오른쪽에 16pt
        )
        
        // 완성된 멤버 섹션 레이아웃을 반환
        return section
    }
    
    // MARK: - 일정 목록을 가로 스크롤 카드로 배치하는 섹션 생성
    private func makeScheduleSection() -> NSCollectionLayoutSection {

        // 일정 카드 한 개의 크기
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),    // 소속 그룹 너비 전체 사용
            heightDimension: .fractionalHeight(1.0)   // 소속 그룹 높이 전체 사용
        )

        // 실제 일정 셀 한 개를 의미
        let item = NSCollectionLayoutItem(
            layoutSize: itemSize
        )

        // 일정 카드 한 장을 담는 그룹 크기
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),   // 화면 너비의 100%
            heightDimension: .absolute(100)           // 카드 높이 120pt
        )

        // 한 그룹 안에 일정 카드 한 개를 가로 방향으로 배치
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )

        // 일정 그룹을 담는 섹션 생성
        let section = NSCollectionLayoutSection(
            group: group
        )

        

        // 일정 카드와 다음 일정 카드 사이 간격
        section.interGroupSpacing = 6

        // 일정 섹션 바깥쪽 여백
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 16,
            bottom: 0,
            trailing: 16
        )
        
        // 헤더 사이즈
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),  // 좌우 전체 사용
            heightDimension: .estimated(20)         // 예상 높이
        )

        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )

        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    // MARK: - 앨범 목록을 가로 스크롤 카드로 배치하는 섹션 생성
    private func makeAlbumSection() -> NSCollectionLayoutSection {

        /*
         앨범 셀 한 개의 크기

         - 한 Group에 앨범 셀 두 개를 배치합니다.
         - 각 셀은 Group 가로 공간의 절반을 사용합니다.
         - 높이는 Group 전체를 사용하여 두 셀의 높이를 동일하게 맞춥니다.
         */
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / 2.0),
            heightDimension: .fractionalHeight(1.0)
        )

        // 앨범 표지와 앨범 정보를 표시할 실제 셀 한 개를 생성합니다.
        let item = NSCollectionLayoutItem(
            layoutSize: itemSize
        )

        /*
         앨범 카드 두 장을 한 줄에 담는 Group 크기

         너비:
         - 화면에서 사용할 수 있는 가로 공간 전체를 사용합니다.
         - Group 내부에서 이 공간을 앨범 셀 두 개가 나누어 사용합니다.

         높이 250pt:
         - 화면 너비에 따라 결정되는 정사각형 앨범 표지
         - 표지와 앨범명 사이 여백 8pt
         - 최대 두 줄 앨범명
         - 발매일과 내부 간격을 표시할 공간을 포함합니다.
         */
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(250)
        )

        // 같은 크기의 앨범 셀을 한 Group 안에 두 개씩 가로로 배치합니다.
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            repeatingSubitem: item,
            count: 2
        )

        // 같은 줄에 있는 두 앨범 카드 사이에 12pt 간격을 둡니다.
        group.interItemSpacing = .fixed(12)

        // 두 개의 앨범을 담은 Group을 아래 방향으로 반복하는 섹션입니다.
        let section = NSCollectionLayoutSection(
            group: group
        )

        // 앨범 두 개로 구성된 줄과 다음 줄 사이의 세로 간격입니다.
        section.interGroupSpacing = 16

        // 앨범 섹션과 화면 가장자리 사이의 여백입니다.
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 16,
            bottom: 20,
            trailing: 16
        )

        // 앨범 섹션 제목을 표시할 헤더의 크기입니다.
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(32)
        )

        // 섹션 상단에 헤더를 배치합니다.
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )

        // 레이아웃이 헤더를 요청할 수 있도록 섹션에 등록합니다.
        section.boundarySupplementaryItems = [header]

        return section
    }
}

// MARK: - 홈 컬렉션뷰에서 표시할 섹션 종류
nonisolated private enum HomeSection: Int, CaseIterable {
    case members       // 멤버 목록 섹션
    case schedules     // 다가오는 일정 섹션
    case albums        // 앨범
    case otherAlbums   // OST등 프로미스나인 이외의 음원 활동
}

// MARK: - 홈 컬렉션뷰에서 표시할 아이템 종류
nonisolated private enum HomeItem: Hashable {
    case member(MemberEntity)               // 멤버 한 명
    case schedule(HomeScheduleCardModel)    // 일정 한 개
    case albums(Album)                             // 앨범
    case otherAlbums(Album)                        // OST등 프로미스나인 이외의 음원 활동
}

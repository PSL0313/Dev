//
//  HomeCollectionViewLayoutFactory.swift
//  flover9
//

import UIKit

// 홈 화면 전체에서 공유하는 정렬선과 간격 규칙
enum HomeLayoutMetric {
    static let horizontalInset: CGFloat = 16          // 섹션의 좌우 여백
    static let sectionSpacing: CGFloat = 32           // 다음 섹션과의 아래 간격
    static let headerToContentSpacing: CGFloat = 12   // 헤더와 첫 콘텐츠의 간격
    static let itemSpacing: CGFloat = 12              // 같은 섹션 아이템 사이 간격
    static let headerEstimatedHeight: CGFloat = 36    // 셀프 사이징 전 헤더 예상 높이
}

// MARK: - 홈 컬렉션뷰의 섹션별 배치만 생성하는 객체
final class HomeCollectionViewLayoutFactory {

    // 섹션 번호에 해당하는 홈 섹션을 제공하는 클로저 타입
    typealias SectionProvider = (Int) -> HomeSection?

    // 각 홈 섹션에 맞는 Compositional Layout을 생성
    func makeLayout(
        sectionProvider: @escaping SectionProvider
    ) -> UICollectionViewLayout {
        // 컬렉션뷰가 섹션을 배치할 때마다 실행되는 레이아웃을 생성
        UICollectionViewCompositionalLayout {
            [weak self] sectionIndex, environment in

            // Factory와 현재 섹션이 모두 존재할 때만 레이아웃을 반환
            guard let self, let section = sectionProvider(sectionIndex) else {
                return nil
            }

            // 섹션 종류에 맞는 전용 레이아웃을 선택
            switch section {
            case .members:
                return makeHeroSection(environment: environment)
            case .schedules:
                return makeScheduleSection()
            case .albums, .otherAlbums:
                return makeAlbumSection()
            }
        }
    }
}

private extension HomeCollectionViewLayoutFactory {

    // Hero와 멤버 콘텐츠를 표시하는 첫 번째 섹션을 생성
    func makeHeroSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let containerWidth = environment.container.effectiveContentSize.width // 실제 표시 가능 너비
        let heroHeight = containerWidth * 9 / 16 + 60                         // 16:9 영역과 하단 멤버 영역 높이

        // Hero 셀 한 개가 사용할 전체 크기
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(heroHeight)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize) // 실제 Hero 셀

        // 한 그룹에 Hero 셀 한 개를 세로 방향으로 배치
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: itemSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group) // Hero 그룹을 담는 섹션
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 0,
            bottom: HomeLayoutMetric.sectionSpacing,
            trailing: 0
        )
        return section
    }

    // 세로로 나열되는 일정 카드 섹션을 생성
    func makeScheduleSection() -> NSCollectionLayoutSection {
        // 일정 제목 줄 수에 따라 실제 높이가 계산되도록 예상 높이를 사용
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(100)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize) // 일정 카드 한 개

        // 한 그룹에 일정 카드 한 개를 세로 방향으로 배치
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: itemSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)                // 일정 목록 섹션
        section.interGroupSpacing = HomeLayoutMetric.itemSpacing             // 일정 카드 사이 간격
        section.contentInsets = regularSectionInsets                         // 공통 좌우·아래 여백
        section.boundarySupplementaryItems = [makeHeader()]                  // 섹션 상단 제목 헤더
        return section
    }

    // 가로로 스크롤되는 앨범 카드 섹션을 생성
    func makeAlbumSection() -> NSCollectionLayoutSection {
        // 앨범 셀이 자신이 속한 그룹 전체를 채우도록 설정
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize) // 앨범 카드 한 개

        // 앨범 카드의 고정 가로·세로 크기를 정의
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(140),
            heightDimension: .absolute(180)
        )

        // 한 그룹에 앨범 카드 한 개를 가로 방향으로 배치
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)                // 앨범 목록 섹션
        section.orthogonalScrollingBehavior = .continuous                    // 세로 화면 안에서 가로 스크롤 허용
        section.interGroupSpacing = HomeLayoutMetric.itemSpacing             // 앨범 카드 사이 간격
        section.contentInsets = regularSectionInsets                         // 공통 좌우·아래 여백
        section.boundarySupplementaryItems = [makeHeader()]                  // 섹션 상단 제목 헤더
        return section
    }

    // 일정과 앨범 섹션에 공통으로 적용할 바깥 여백
    var regularSectionInsets: NSDirectionalEdgeInsets {
        NSDirectionalEdgeInsets(
            top: 0,
            leading: HomeLayoutMetric.horizontalInset,
            bottom: HomeLayoutMetric.sectionSpacing,
            trailing: HomeLayoutMetric.horizontalInset
        )
    }

    // 일정과 앨범 섹션에서 공유하는 제목 헤더를 생성
    func makeHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        // 헤더는 가로 전체를 사용하고 실제 콘텐츠에 맞춰 높이를 조정
        let size = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(HomeLayoutMetric.headerEstimatedHeight)
        )

        // 생성한 헤더를 섹션의 가장 위쪽에 배치
        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: size,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
    }
}

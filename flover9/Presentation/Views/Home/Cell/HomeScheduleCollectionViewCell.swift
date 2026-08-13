//
//  HomeScheduleCollectionViewCell.swift
//  flover9
//
//  Created by 박선린 on 8/12/26.
//


import UIKit

// MARK: - 홈 화면에서 다가오는 일정 하나를 표시하는 컬렉션뷰 셀
final class HomeScheduleCollectionViewCell: UICollectionViewCell {

    // MARK: - 컬렉션뷰에서 셀을 재사용하기 위한 식별자
    static let reuseIdentifier = String(
        describing: HomeScheduleCollectionViewCell.self
    )

    // MARK: - UI
    // 일정 제목을 표시하는 레이블
    private let titleLabel: UILabel = {
        let label = UILabel()

        label.font = .systemFont(
            ofSize: 17,
            weight: .semibold
        )
        label.textColor = .white
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    // 일정 날짜와 시간을 표시하는 레이블
    private let dateLabel: UILabel = {
        let label = UILabel()

        label.font = .systemFont(
            ofSize: 14,
            weight: .medium
        )
        label.textColor = .systemGreen
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    // 일정 장소를 표시하는 레이블
    private let venueLabel: UILabel = {
        let label = UILabel()

        label.font = .systemFont(
            ofSize: 13,
            weight: .regular
        )
        label.textColor = .white.withAlphaComponent(0.6)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    // MARK: - 코드로 셀을 생성할 때 호출되는 초기화 함수
    override init(frame: CGRect) {
        super.init(frame: frame)

        configureAppearance()                    // 셀 배경 스타일 설정
        setLayout()                              // 셀 내부 레이아웃 설정
    }

    // MARK: - Storyboard와 XIB를 통한 생성을 제한
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 셀이 재사용되기 전 이전 데이터 초기화
    override func prepareForReuse() {
        super.prepareForReuse()

        titleLabel.text = nil                    // 이전 일정 제목 제거
        dateLabel.text = nil                     // 이전 일정 날짜 제거
        venueLabel.text = nil                    // 이전 일정 장소 제거
    }

    // MARK: - 전달받은 일정 정보를 셀에 표시
    func configure(with schedule: ScheduleEntity) {
        titleLabel.text = schedule.title         // 일정 제목 표시
        dateLabel.text = formatDate(
            schedule.startAt
        )                                        // 시작 날짜 표시
        venueLabel.text = schedule.venueName     // 일정 장소 표시
    }
}

private extension HomeScheduleCollectionViewCell {

    // MARK: - 일정 셀의 외형 설정
    func configureAppearance() {
        contentView.backgroundColor = UIColor(
            white: 0.1,
            alpha: 1
        )
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
    }

    // MARK: - 일정 셀 내부 레이아웃 설정
    func setLayout() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(venueLabel)

        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 16
            ),
            dateLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16
            ),
            dateLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: contentView.trailingAnchor,
                constant: -16
            ),

            titleLabel.topAnchor.constraint(
                equalTo: dateLabel.bottomAnchor,
                constant: 8
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16
            ),

            venueLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 8
            ),
            venueLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16
            ),
            venueLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16
            ),
            venueLabel.bottomAnchor.constraint(
                lessThanOrEqualTo: contentView.bottomAnchor,
                constant: -16
            )
        ])
    }

    // MARK: - 일정 시작 날짜를 화면 표시용 문자열로 변환
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()

        formatter.locale = Locale(
            identifier: "ko_KR"
        )
        formatter.timeZone = TimeZone(
            identifier: "Asia/Seoul"
        )
        formatter.dateFormat = "M월 d일 (E) HH:mm"

        return formatter.string(from: date)
    }
}

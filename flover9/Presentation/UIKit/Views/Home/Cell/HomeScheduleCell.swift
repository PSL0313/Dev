//
//  HomeScheduleCell.swift
//  flover9
//
//  Created by 박선린 on 8/13/26.
//
import UIKit
import SnapKit
import Kingfisher

final class HomeScheduleCell: UICollectionViewCell {

    static let reuseIdentifier = String(describing: HomeScheduleCell.self)

    // MARK: - UI

    /// D-Day 배지를 왼쪽에 배치하기 위한 투명 컨테이너.
    ///
    /// contentStackView의 alignment가 .fill이기 때문에
    /// dDayLabel을 직접 arrangedSubview로 넣으면 가로 전체를 차지하게 된다.
    /// 따라서 한 줄 전체를 담당하는 투명 View 안에 실제 배지만 따로 배치한다.
    private let dDayRowView = UIView()

    /// 일정까지 남은 날짜를 표시하는 배지.
    ///
    /// 배경색은 이 Label 자체에만 적용되므로
    /// "D-27" 영역만 초록색 배경을 가진다.
    private let dDayLabel: PaddingLabel = {
        let label = PaddingLabel(
            top: 3,
            left: 7,
            bottom: 3,
            right: 7
        )

        label.font = .systemFont(
            ofSize: 9,
            weight: .semibold
        )

        label.textColor = .label

        label.backgroundColor = .systemGreen.withAlphaComponent(0.16)

        label.layer.cornerRadius = 5
        label.clipsToBounds = true

        return label
    }()

    /// 일정 제목.
    private let titleLabel: UILabel = {
        let label = UILabel()

        label.font = .systemFont(
            ofSize: 15,
            weight: .regular
        )

        label.textColor = .label
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail

        return label
    }()

    /// 날짜와 시간을 하나의 문자열로 표시한다.
    ///
    /// HomeScheduleCardModel에서 이미 화면용 문자열로 만들어 전달하므로
    /// 셀에서는 별도의 날짜 계산이나 포맷팅을 하지 않는다.
    private let scheduleLabel: UILabel = {
        let label = UILabel()

        label.font = .systemFont(
            ofSize: 11,
            weight: .medium
        )

        // 참고 이미지처럼 날짜/시간에 포인트 컬러 적용
        label.textColor = .systemGreen

        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail

        return label
    }()

    /// 장소 앞에 표시되는 SF Symbol 위치 아이콘.
    private let venueImageView: UIImageView = {
        let imageView = UIImageView(
            image: UIImage(systemName: "mappin")
        )

        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .scaleAspectFit

        return imageView
    }()

    /// 일정 장소 이름.
    private let venueLabel: UILabel = {
        let label = UILabel()

        label.font = .systemFont(
            ofSize: 11,
            weight: .regular
        )

        label.textColor = .secondaryLabel

        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail

        return label
    }()

    /// 위치 아이콘 + 장소명을 한 줄로 묶는 StackView.
    private lazy var venueStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                venueImageView,
                venueLabel
            ]
        )

        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 4

        return stackView
    }()

    /// 참여 멤버 프로필 이미지.
    ///
    /// 현재 멤버가 최대 5명이므로 UICollectionView를 중첩하지 않고
    /// UIImageView 5개를 미리 만들어 StackView에서 재사용한다.
    private lazy var participantImageViews: [UIImageView] = {
        (0..<5).map { _ in
            let imageView = UIImageView()

            imageView.backgroundColor = .tertiarySystemFill
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true

            // 24 × 24 원형 프로필
            imageView.layer.cornerRadius = 12

            // configure 전에는 숨겨둔다.
            imageView.isHidden = true

            imageView.snp.makeConstraints {
                $0.size.equalTo(24)
            }

            return imageView
        }
    }()

    /// 화면에 표시되지 못한 추가 참여자 수.
    ///
    /// 예: +1, +2
    private let remainingCountLabel: UILabel = {
        let label = UILabel()

        label.backgroundColor = .tertiarySystemFill

        label.font = .systemFont(
            ofSize: 10,
            weight: .medium
        )

        label.textColor = .secondaryLabel
        label.textAlignment = .center

        label.clipsToBounds = true
        label.layer.cornerRadius = 12

        label.isHidden = true

        label.snp.makeConstraints {
            $0.size.equalTo(24)
        }

        return label
    }()

    /// 참여 멤버 이미지들을 가로로 배치하는 StackView.
    private lazy var participantStackView: UIStackView = {
        let arrangedSubviews =
            participantImageViews +
            [remainingCountLabel]

        let stackView = UIStackView(
            arrangedSubviews: arrangedSubviews
        )

        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 4

        return stackView
    }()

    /// 장소와 참여 멤버 사이의 남는 영역을 차지한다.
    ///
    /// 결과적으로 장소는 왼쪽,
    /// 참여 멤버는 오른쪽에 정렬된다.
    private let spacerView = UIView()

    /// 카드 가장 아래의 장소 + 참여 멤버 영역.
    private lazy var venueAndScheduleStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                scheduleLabel,
                venueStackView
            ]
        )

        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 8

        return stackView
    }()
    
    /// 카드 가장 아래의 장소 + 참여 멤버 영역.
    private lazy var bottomStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                venueAndScheduleStackView,
                spacerView,
                participantStackView
            ]
        )

        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8

        return stackView
    }()

    /// 카드의 주요 콘텐츠를 세로 방향으로 배치한다.
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                dDayRowView,
                titleLabel,
                bottomStackView
            ]
        )

        stackView.axis = .vertical
        stackView.alignment = .fill

        // 각 행 사이의 간격은 아래에서 별도로 조정한다.
        stackView.spacing = 0

        return stackView
    }()

    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureUI()
        configureHierarchy()
        configureConstraints()
        configurePriority()
        configureStackSpacing()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()

        // 이전 셀의 텍스트 제거
        dDayLabel.text = nil
        titleLabel.text = nil
        scheduleLabel.text = nil
        venueLabel.text = nil

        // 진행 중인 이미지 다운로드를 취소하고
        // 이미지 View를 초기 상태로 되돌린다.
        participantImageViews.forEach { imageView in
            imageView.kf.cancelDownloadTask()
            imageView.image = nil
            imageView.isHidden = true
        }

        remainingCountLabel.text = nil
        remainingCountLabel.isHidden = true
    }
}

// MARK: - Configure

extension HomeScheduleCell {

    /// ViewModel에서 가공된 화면용 모델을 셀에 표시한다.
    ///
    /// 날짜 계산, D-Day 계산, 참여 멤버 수 계산 등은
    /// 셀이 하지 않고 전달받은 값을 그대로 표시한다.
    func configure(with model: HomeScheduleCardModel) {
        dDayLabel.text = model.dDayText
        titleLabel.text = model.title
        scheduleLabel.text = model.scheduleText
        venueLabel.text = model.venueName

        configureParticipants(
            imageURLs: model.participantImageURLs,
            remainingCount: model.remainingParticipantCount
        )
        backgroundColor = .clear
    }

    /// 참여 멤버 이미지를 설정한다.
    private func configureParticipants(
        imageURLs: [URL?],
        remainingCount: Int
    ) {
        // CollectionViewCell 재사용을 고려해
        // 기존 이미지 상태를 먼저 초기화한다.
        participantImageViews.forEach { imageView in
            imageView.kf.cancelDownloadTask()
            imageView.image = nil
            imageView.isHidden = true
        }

        // 최대 5명의 참여 멤버 이미지만 표시한다.
        for (imageView, imageURL) in zip(
            participantImageViews,
            imageURLs.prefix(5)
        ) {
            imageView.isHidden = false

            // URL이 없는 경우에는 기본 배경색만 표시한다.
            guard let imageURL else {
                continue
            }

            imageView.kf.setImage(
                with: imageURL
            )
        }

        // 표시하지 못한 멤버가 있다면 +N 형태로 표시한다.
        if remainingCount > 0 {
            remainingCountLabel.text = "+\(remainingCount)"
            remainingCountLabel.isHidden = false
        } else {
            remainingCountLabel.text = nil
            remainingCountLabel.isHidden = true
        }
    }
}

// MARK: - UI

private extension HomeScheduleCell {

    /// 셀 자체의 시각적 스타일을 설정한다.
    func configureUI() {
        contentView.backgroundColor = .systemBackground
    }

    /// View hierarchy를 구성한다.
    func configureHierarchy() {
        contentView.addSubview(contentStackView)

        // D-Day 전체 행은 투명하고
        // 실제 배지만 내부에 별도로 배치한다.
        dDayRowView.addSubview(dDayLabel)
    }

    /// Auto Layout 제약 조건을 설정한다.
    func configureConstraints() {

        // 참고 이미지 기준 약 16pt 좌우,
        // 약 10pt 상하 내부 여백
        contentStackView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.verticalEdges.equalToSuperview()
        }

        // D-Day 배지는 왼쪽에만 붙이고
        // trailing 제약을 주지 않는다.
        //
        // Label의 intrinsicContentSize만큼만
        // 초록색 배경을 가진다.
        dDayLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.verticalEdges.equalToSuperview()
        }

        // 참고 이미지 비율 기준 위치 아이콘 크기
        venueImageView.snp.makeConstraints {
            $0.size.equalTo(13)
        }

        // 하단 행은 멤버 프로필 높이에 맞춘다.
        bottomStackView.snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(24)
        }
    }

    /// Auto Layout 우선순위를 조정한다.
    func configurePriority() {

        // 장소명이 길어질 경우
        // 멤버 이미지보다 장소 문자열이 먼저 줄어들게 한다.
        venueLabel.setContentCompressionResistancePriority(
            .defaultLow,
            for: .horizontal
        )

        // 멤버 이미지 영역은 가능한 한 원래 너비를 유지한다.
        participantStackView.setContentCompressionResistancePriority(
            .required,
            for: .horizontal
        )

        // 가운데 Spacer가 남은 가로 공간을 차지한다.
        spacerView.setContentHuggingPriority(
            .defaultLow,
            for: .horizontal
        )

        spacerView.setContentCompressionResistancePriority(
            .defaultLow,
            for: .horizontal
        )
    }

    /// 참고 이미지의 각 행 간격에 가깝게 개별 spacing을 설정한다.
    func configureStackSpacing() {
        contentStackView.setCustomSpacing(
            5,
            after: dDayRowView
        )

        contentStackView.setCustomSpacing(
            5,
            after: titleLabel
        )

        contentStackView.setCustomSpacing(
            4,
            after: scheduleLabel
        )
    }
}

final class PaddingLabel: UILabel {

    private let padding: UIEdgeInsets

    init(
        top: CGFloat,
        left: CGFloat,
        bottom: CGFloat,
        right: CGFloat
    ) {
        self.padding = UIEdgeInsets(
            top: top,
            left: left,
            bottom: bottom,
            right: right
        )

        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func drawText(in rect: CGRect) {
        super.drawText(
            in: rect.inset(by: padding)
        )
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize

        return CGSize(
            width: size.width + padding.left + padding.right,
            height: size.height + padding.top + padding.bottom
        )
    }
}

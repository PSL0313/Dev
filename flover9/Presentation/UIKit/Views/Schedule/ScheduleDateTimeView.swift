//
//  ScheduleDateTimeView.swift
//  flover9
//
//  Created by 박선린 on 9/14/26.
//
import UIKit
import SnapKit

/// 스케줄 상세 화면에서 날짜와 세부 시간을 보여주는 뷰
/// UIControl 내부에 존재하는 (터치 감지가 필요 없는)뷰들은 .isUserInteractionEnabled = false 하여 터치 이벤트를 가져가지 않게 방지하기
final class ScheduleDateTimeView: UIControl {

    // MARK: - UI

    private let calendarImageView: UIImageView = {
        let imageView = UIImageView()

        let configuration = UIImage.SymbolConfiguration(
            pointSize: 13,
            weight: .semibold
        )
        
        imageView.image = UIImage(
            systemName: "calendar.badge.plus",
            withConfiguration: configuration
        )

        imageView.tintColor = .label
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false

        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "일시"
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.isUserInteractionEnabled = false
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .label
        label.isUserInteractionEnabled = false
        return label
    }()

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.isUserInteractionEnabled = false
        return label
    }()

    /// 왼쪽: 캘린더 / 일시
    private lazy var calendarStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                calendarImageView,
                titleLabel
            ]
        )

        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        stackView.isUserInteractionEnabled = false
        return stackView
    }()

    /// 오른쪽: 날짜 / 시간
    private lazy var dateAndTimeStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                dateLabel,
                timeLabel
            ]
        )

        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fillEqually
        stackView.spacing = 2
        stackView.isUserInteractionEnabled = false
        return stackView
    }()

    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        view.isUserInteractionEnabled = false
        return view
    }()

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                calendarStackView,
                dividerView,
                dateAndTimeStackView
            ]
        )

        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 14
        stackView.isUserInteractionEnabled = false
        return stackView
    }()


    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Layout

    private func configureLayout() {
        addSubview(contentStackView)

        calendarStackView.snp.makeConstraints {
            $0.width.equalTo(40)
        }

        dividerView.snp.makeConstraints {
            $0.width.equalTo(1)
        }

        contentStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(14)
        }
    }


    // MARK: - Configure

    func configure(date: String, time: String) {
        dateLabel.text = date
        timeLabel.text = time
    }
}

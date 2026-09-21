//
//  ScheduleStatusView.swift
//  flover9
//
//  Created by 박선린 on 9/14/26.
//


import UIKit
import SnapKit

final class ScheduleStatusView: UIView {

    // MARK: - UI

    /// "뮤지컬" 배경
    private let categoryContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(
            red: 0.22,
            green: 0.12,
            blue: 0.10,
            alpha: 1
        )

        view.layer.cornerRadius = 8
        view.layer.cornerCurve = .continuous

        return view
    }()

    /// 카테고리명(콘서트, 뮤지컬 등
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .semibold)

        label.textColor = UIColor(
            red: 1.0,
            green: 0.42,
            blue: 0.31,
            alpha: 1
        )

        return label
    }()

    /// 가운데 점
    private let dotLabel: UILabel = {
        let label = UILabel()
        label.text = "•"
        label.font = .systemFont(ofSize: 8, weight: .medium)
        label.textColor = .secondaryLabel

        return label
    }()

    /// "진행 예정"
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .regular)
        label.textColor = .secondaryLabel

        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                categoryContainerView,
                dotLabel,
                statusLabel
            ]
        )

        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 10

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


    // MARK: - Configure

    func configure(
        category: ScheduleType,
        status: ScheduleStatus
    ) {
        categoryLabel.text = category.categoryName()
        statusLabel.text = status.statusName()
        configureCategoryColor(category: category)
    }
}


// MARK: - Layout

private extension ScheduleStatusView {

    func configureLayout() {
        addSubview(stackView)
        categoryContainerView.addSubview(categoryLabel)

        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        categoryLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(6)
            $0.leading.trailing.equalToSuperview().inset(10)
        }
    }
    
    func configureCategoryColor(
        category: ScheduleType
    ) {
        
        switch category {
        case .concert:
            categoryContainerView.backgroundColor = UIColor(
                red: 0.18,
                green: 0.12,
                blue: 0.28,
                alpha: 1
            )

            categoryLabel.textColor = UIColor(
                red: 0.72,
                green: 0.55,
                blue: 1.0,
                alpha: 1
            )

        case .fanMeeting:
            categoryContainerView.backgroundColor = UIColor(
                red: 0.27,
                green: 0.10,
                blue: 0.20,
                alpha: 1
            )

            categoryLabel.textColor = UIColor(
                red: 1.0,
                green: 0.46,
                blue: 0.72,
                alpha: 1
            )

        case .fanSigning:
            categoryContainerView.backgroundColor = UIColor(
                red: 0.28,
                green: 0.12,
                blue: 0.14,
                alpha: 1
            )

            categoryLabel.textColor = UIColor(
                red: 1.0,
                green: 0.46,
                blue: 0.50,
                alpha: 1
            )

        case .musical:
            categoryContainerView.backgroundColor = UIColor(
                red: 0.22,
                green: 0.12,
                blue: 0.10,
                alpha: 1
            )

            categoryLabel.textColor = UIColor(
                red: 1.0,
                green: 0.42,
                blue: 0.31,
                alpha: 1
            )

        case .festival:
            categoryContainerView.backgroundColor = UIColor(
                red: 0.28,
                green: 0.17,
                blue: 0.07,
                alpha: 1
            )

            categoryLabel.textColor = UIColor(
                red: 1.0,
                green: 0.64,
                blue: 0.23,
                alpha: 1
            )

        case .broadcast:
            categoryContainerView.backgroundColor = UIColor(
                red: 0.08,
                green: 0.16,
                blue: 0.28,
                alpha: 1
            )

            categoryLabel.textColor = UIColor(
                red: 0.38,
                green: 0.68,
                blue: 1.0,
                alpha: 1
            )

        case .liveStream:
            categoryContainerView.backgroundColor = UIColor(
                red: 0.06,
                green: 0.22,
                blue: 0.22,
                alpha: 1
            )

            categoryLabel.textColor = UIColor(
                red: 0.33,
                green: 0.86,
                blue: 0.82,
                alpha: 1
            )

        case .release:
            categoryContainerView.backgroundColor = UIColor(
                red: 0.08,
                green: 0.22,
                blue: 0.14,
                alpha: 1
            )

            categoryLabel.textColor = UIColor(
                red: 0.38,
                green: 0.86,
                blue: 0.54,
                alpha: 1
            )

        case .content:
            categoryContainerView.backgroundColor = UIColor(
                red: 0.13,
                green: 0.13,
                blue: 0.29,
                alpha: 1
            )

            categoryLabel.textColor = UIColor(
                red: 0.55,
                green: 0.60,
                blue: 1.0,
                alpha: 1
            )

        case .event:
            categoryContainerView.backgroundColor = UIColor(
                red: 0.27,
                green: 0.22,
                blue: 0.08,
                alpha: 1
            )

            categoryLabel.textColor = UIColor(
                red: 1.0,
                green: 0.78,
                blue: 0.28,
                alpha: 1
            )

        case .other:
            categoryContainerView.backgroundColor = UIColor(
                red: 0.18,
                green: 0.18,
                blue: 0.20,
                alpha: 1
            )

            categoryLabel.textColor = UIColor(
                red: 0.72,
                green: 0.72,
                blue: 0.76,
                alpha: 1
            )
        }
    }
}

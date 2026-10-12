//
//  ScheduleReservationControl.swift
//  flover9
//
//  Created by 박선린 on 9/14/26.
//

import UIKit
import SnapKit

/// 일정 상세 화면 하단의 예매 바로가기 Control
final class ScheduleReservationControl: UIControl {

    // MARK: - UI
    
    /// 글래스 이펙트뷰
    private let glassView: UIVisualEffectView = {
        let effect = UIGlassEffect()
        effect.isInteractive = true

        let view = UIVisualEffectView(effect: effect)
        view.isUserInteractionEnabled = false // 터치 이벤트 비활성화
        
        return view
    }()

    /// 버튼 타이틀
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Continue to Ticketing"
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .systemBackground
        return label
    }()

    /// 설명 및 경고
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "예매 사이트에서 회차와 좌석을 확인해주세요"
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondarySystemBackground
        label.textAlignment = .center
        return label
    }()

    /// 이미지뷰 - ↗
    private let shortcutImageView: UIImageView = {
        let imageView = UIImageView()

        let configuration = UIImage.SymbolConfiguration(
            pointSize: 14,
            weight: .semibold
        )

        imageView.image = UIImage(
            systemName: "arrow.up.right",
            withConfiguration: configuration
        )

        imageView.tintColor = .systemBackground
        imageView.contentMode = .scaleAspectFit

        return imageView
    }()

    /// "예매하기 ↗"
    private lazy var titleStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                titleLabel,
                shortcutImageView
            ]
        )

        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 6

        return stackView
    }()

    /// 제목 + 설명
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                titleStackView,
                descriptionLabel
            ]
        )

        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 3

        // UIControl이 터치를 전부 받도록 함
        stackView.isUserInteractionEnabled = false

        return stackView
    }()


    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureStyle()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Highlight

    /// 눌렀을 때 살짝 작아지는 효과
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(
                withDuration: 0.15,
                delay: 0,
                options: [
                    .allowUserInteraction,
                    .beginFromCurrentState
                ]
            ) {
                self.transform = self.isHighlighted
                    ? CGAffineTransform(scaleX: 0.97, y: 0.97)
                    : .identity

                self.alpha = self.isHighlighted
                    ? 0.82
                    : 1.0
            }
        }
    }
}


// MARK: - Configuration

private extension ScheduleReservationControl {

    func configureStyle() {
        backgroundColor = .clear

        layer.cornerRadius = 20
        layer.cornerCurve = .continuous
        layer.masksToBounds = true

        // 살짝 떠 있는 느낌
        glassView.layer.borderWidth = 0.5
        glassView.layer.borderColor =
            UIColor.white.withAlphaComponent(0.25).cgColor
        
        // 해당 뷰의 백그라운드 색상은 클리어 색상으로 두고, 글래스뷰에 적용
        glassView.backgroundColor = UIColor.label.withAlphaComponent(0.6)
        
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = 0.12
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: 4)
    }

    func configureLayout() {
        addSubview(glassView)
        addSubview(contentStackView)
        
        glassView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        shortcutImageView.snp.makeConstraints {
            $0.width.height.equalTo(16)
        }

        contentStackView.snp.makeConstraints {
            $0.center.equalToSuperview()

            // 작은 화면에서 텍스트가 바깥으로 나가지 않도록 제한
            $0.leading.greaterThanOrEqualToSuperview().offset(20)
            $0.trailing.lessThanOrEqualToSuperview().offset(-20)
        }

        snp.makeConstraints {
            $0.height.equalTo(68)
        }
    }
}

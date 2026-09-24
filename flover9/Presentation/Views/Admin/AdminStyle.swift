import UIKit
import SnapKit

// MARK: - 관리자 화면에서 공통으로 사용하는 간격과 스타일
enum AdminStyle {
    static let accent = UIColor.systemTeal
    static let inset: CGFloat = 20

    // 다른 탭의 내비게이션 스타일과 관계없이 제목의 명암을 유지한다.
    static func configureNavigationBar(_ navigationBar: UINavigationBar) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = .systemGroupedBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.tintColor = accent
    }

    static func label(_ text: String, style: UIFont.TextStyle, color: UIColor = .label) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .preferredFont(forTextStyle: style)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = color
        label.numberOfLines = 0
        return label
    }

    static func button(_ title: String, symbol: String, primary: Bool = true) -> UIButton {
        var configuration = primary ? UIButton.Configuration.filled() : .tinted()
        configuration.title = title
        configuration.image = UIImage(systemName: symbol)
        configuration.imagePadding = 8
        configuration.baseBackgroundColor = accent
        configuration.cornerStyle = .large
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 18, bottom: 16, trailing: 18)
        return UIButton(configuration: configuration)
    }
}

// MARK: - 라벨과 입력칸을 묶어 placeholder에만 설명을 의존하지 않는다.
final class AdminTextField: UIStackView {
    let input = UITextField()

    init(title: String, value: String = "", placeholder: String = "", isURL: Bool = false) {
        super.init(frame: .zero)
        axis = .vertical
        spacing = 8
        addArrangedSubview(AdminStyle.label(title, style: .subheadline, color: .secondaryLabel))

        input.text = value
        input.placeholder = placeholder
        input.font = .preferredFont(forTextStyle: .body)
        input.adjustsFontForContentSizeCategory = true
        input.borderStyle = .roundedRect
        input.backgroundColor = .tertiarySystemGroupedBackground
        input.clearButtonMode = .whileEditing
        input.accessibilityLabel = title
        if isURL {
            input.keyboardType = .URL
            input.autocapitalizationType = .none
            input.autocorrectionType = .no
        }
        addArrangedSubview(input)
        input.snp.makeConstraints { $0.height.greaterThanOrEqualTo(48) }
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var value: String {
        input.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
}

// MARK: - 설명과 공지를 위한 여러 줄 입력
final class AdminTextArea: UIStackView {
    let input = UITextView()

    init(title: String, value: String) {
        super.init(frame: .zero)
        axis = .vertical
        spacing = 8
        addArrangedSubview(AdminStyle.label(title, style: .subheadline, color: .secondaryLabel))
        input.text = value
        input.font = .preferredFont(forTextStyle: .body)
        input.adjustsFontForContentSizeCategory = true
        input.backgroundColor = .tertiarySystemGroupedBackground
        input.layer.cornerRadius = 12
        input.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        input.accessibilityLabel = title
        addArrangedSubview(input)
        input.snp.makeConstraints { $0.height.equalTo(140) }
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var value: String {
        input.text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

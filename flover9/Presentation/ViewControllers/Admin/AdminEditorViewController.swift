import UIKit
import SnapKit
import UniformTypeIdentifiers
import PhotosUI

final class AdminEditorViewController: UIViewController, UIDocumentPickerDelegate, UITextViewDelegate, PHPickerViewControllerDelegate {
    // MARK: - Properties
    private let viewModel: AdminEditorViewModel
    var onClose: ((Bool) -> Void)?             // 변경 여부를 코디네이터에 전달
    var onMessage: ((String) -> Void)?
    var onPreview: (([FeedImageEntity], Int) -> Void)?
    private var hasChanges = false
    private var isImporting = false
    private var importedDirectories: [URL] = []
    private var selectedMembers: [MemberCode] = []

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let footer = UIView()
    private let saveButton = AdminStyle.button("저장하기", symbol: "checkmark")
    private let spinner = UIActivityIndicatorView(style: .large)
    private let titleField = AdminTextField(title: "제목 *")
    private let nameField = AdminTextField(title: "출처 이름", placeholder: "예: 공식 인스타그램")
    private let descriptionField = AdminTextArea(title: "설명", value: "")
    private let urlField = AdminTextField(title: "원본 링크 (선택)", placeholder: "주소가 있는 경우에만 입력해 주세요", isURL: true)
    private let venueField = AdminTextField(title: "장소", placeholder: "장소 이름")
    private let reservationField = AdminTextField(title: "예매 링크", placeholder: "https://", isURL: true)
    private let thumbnailField = AdminTextField(title: "대표 이미지 주소", placeholder: "https://", isURL: true)
    private let zoneField = AdminTextField(title: "시간대", placeholder: "Asia/Seoul")
    private let startPicker = UIDatePicker()
    private let endPicker = UIDatePicker()
    private let endToggle = UISwitch()
    private let allDayToggle = UISwitch()
    private let filesLabel = AdminStyle.label("선택한 파일이 없어요", style: .footnote, color: .secondaryLabel)
    private let filesButton = AdminStyle.button("사진·MP4 파일 선택", symbol: "plus.rectangle.on.folder", primary: false)
    private let photosButton = AdminStyle.button("사진 보관함에서 선택", symbol: "photo.on.rectangle", primary: false)
    private let mediaStrip = AdminMediaStripView()
    private let memberStack = UIStackView()

    init(viewModel: AdminEditorViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        // 이 편집기가 만든 임시 폴더만 정리한다. 원본 파일은 건드리지 않는다.
        importedDirectories.forEach { try? FileManager.default.removeItem(at: $0) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.mode.title
        // 미디어가 있는 화면에서도 제목은 시스템 글자색으로 표시한다.
        navigationItem.titleView = AdminStyle.label(viewModel.mode.title, style: .headline)
        configureLayout()
        configureForm()
        configureActions()
        bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.checkAccess()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    private func configureLayout() {
        view.backgroundColor = .systemGroupedBackground
        view.addSubview(scrollView)
        view.addSubview(footer)
        view.addSubview(spinner)
        scrollView.addSubview(stackView)
        scrollView.keyboardDismissMode = .onDrag
        footer.backgroundColor = .secondarySystemGroupedBackground
        footer.addSubview(saveButton)
        stackView.axis = .vertical
        stackView.spacing = 20

        footer.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
        }
        saveButton.snp.makeConstraints { $0.edges.equalToSuperview().inset(16) }
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(footer.snp.top)
        }
        stackView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide).inset(20)
            $0.width.equalTo(scrollView.frameLayoutGuide).offset(-40)
        }
        spinner.snp.makeConstraints { $0.center.equalToSuperview() }

        navigationItem.hidesBackButton = true
        if !viewModel.mode.isNew {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "전체 삭제", image: UIImage(systemName: "trash"),
                primaryAction: UIAction { [weak self] _ in
                    guard let self, !isImporting else { return }
                    viewModel.requestDeletion()
                }
            )
            navigationItem.rightBarButtonItem?.tintColor = .systemRed
            navigationItem.rightBarButtonItem?.accessibilityLabel = "전체 삭제"
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "취소",
            primaryAction: UIAction { [weak self] _ in
                guard let self, !viewModel.isSaving, !isImporting else { return }
                onClose?(hasChanges)
            }
        )
    }

    // MARK: - 각 편집 화면에 필요한 입력만 배치
    private func configureForm() {
        // 미디어를 가장 먼저 배치해 수정할 대상을 바로 확인합니다.
        stackView.addArrangedSubview(mediaStrip)
        stackView.addArrangedSubview(filesLabel)
        stackView.addArrangedSubview(photosButton)
        stackView.addArrangedSubview(filesButton)
        mediaStrip.onPreview = { [weak self] index in
            guard let self else { return }
            onPreview?(viewModel.previewItems, index)
        }
        mediaStrip.onToggleRemoval = { [weak self] id in
            self?.hasChanges = true
            self?.viewModel.toggleRemoval(id)
        }
        photosButton.addAction(UIAction { [weak self] _ in self?.choosePhotos() }, for: .touchUpInside)
        filesButton.addAction(UIAction { [weak self] _ in self?.chooseFiles() }, for: .touchUpInside)
        viewModel.onMediaChange = { [weak self] in self?.renderMedia() }
        renderMedia()
        if viewModel.mediaCategory != .feeds {
            configureMenu(title: "추가할 이미지 용도", options: [("hero", "상단 배너"), ("content", "상세 콘텐츠")], selected: viewModel.mediaEdit.displayRole) { [weak self] role in
                self?.viewModel.mediaEdit.displayRole = role
            }
        }
        switch viewModel.mode {
        case .newFeed, .editFeed:
            configureFeedForm()
        case .newSchedule(let event):
            configureScheduleForm(event: event)
        case .editSchedule(let schedule):
            configureScheduleForm(event: schedule.event)
        case .newEvent, .editEvent:
            configureEventForm()
        }
    }

    private func configureFeedForm() {
        addGuide(viewModel.mode.isNew
            ? "모든 파일의 업로드가 끝난 뒤 피드를 등록해요. 파일은 최대 20개, 파일당 1GB까지 선택할 수 있어요."
            : "사진의 X는 삭제 예약이에요. 저장하기를 눌러야 반영되며, 취소하면 원본이 유지돼요.")
        titleField.input.text = viewModel.feed.title
        nameField.input.text = viewModel.feed.sourceName
        descriptionField.input.text = viewModel.feed.description
        urlField.input.text = viewModel.feed.permalink
        [titleField, nameField, descriptionField].forEach(stackView.addArrangedSubview)
        addDatePicker(startPicker, title: "촬영 날짜", date: viewModel.feed.captureDate)

        guard viewModel.mode.isNew else { return }
        stackView.addArrangedSubview(urlField)
        configureMenu(
            title: "출처",
            options: [("blogger", "직접 등록"), ("instagram", "인스타그램"), ("fromm", "프롬")],
            selected: viewModel.feed.source
        ) { [weak self] value in self?.viewModel.feed.source = value }

        addSectionTitle("등장 멤버 *")
        memberStack.axis = .vertical
        memberStack.spacing = 8
        let members: [(MemberCode, String)] = [
            (.hayoung, "송하영"), (.jiwon, "박지원"), (.chaeyoung, "이채영"),
            (.nagyung, "이나경"), (.jiheon, "백지헌")
        ]
        for (code, name) in members {
            let button = AdminStyle.button(name, symbol: "circle", primary: false)
            button.addAction(UIAction { [weak self, weak button] _ in
                guard let self, let button else { return }
                if let index = selectedMembers.firstIndex(of: code) {
                    selectedMembers.remove(at: index)
                } else {
                    selectedMembers.append(code)
                }
                let selected = selectedMembers.contains(code)
                button.configuration?.image = UIImage(systemName: selected ? "checkmark.circle.fill" : "circle")
                button.accessibilityValue = selected ? "선택됨" : "선택 안 됨"
                hasChanges = true
            }, for: .touchUpInside)
            memberStack.addArrangedSubview(button)
        }
        stackView.addArrangedSubview(memberStack)
    }

    private func configureScheduleForm(event: ScheduleEventEntity) {
        guard let draft = viewModel.schedule else { return }
        addGuide("\(event.title)\n행사에 속한 개별 날짜·시간을 편집해요. 제목·설명·예매 링크는 행사 관리에서 변경할 수 있어요.")
        addDatePicker(startPicker, title: "시작 *", date: draft.startAt)
        addToggle(allDayToggle, title: "종일 일정", isOn: draft.isAllDay)
        addToggle(endToggle, title: "종료 시간 설정", isOn: draft.endAt != nil)
        addDatePicker(endPicker, title: "종료", date: draft.endAt ?? draft.startAt.addingTimeInterval(3600))
        endPicker.isEnabled = endToggle.isOn
        startPicker.timeZone = TimeZone(identifier: draft.timeZone)
        endPicker.timeZone = TimeZone(identifier: draft.timeZone)
        zoneField.input.text = draft.timeZone
        zoneField.input.autocapitalizationType = .none
        zoneField.input.autocorrectionType = .no
        venueField.input.text = draft.venueName
        venueField.input.placeholder = event.venueName.map { "공통 장소: \($0)" } ?? "비워두면 행사 장소 사용"
        stackView.addArrangedSubview(zoneField)
        stackView.addArrangedSubview(venueField)
        let statuses: [ScheduleStatus] = [.scheduled, .delayed, .postponed, .cancelled, .completed]
        configureMenu(
            title: "진행 상태",
            options: statuses.map { ($0.rawValue, $0.statusName()) },
            selected: draft.status.rawValue
        ) { [weak self] value in
            self?.viewModel.schedule?.status = ScheduleStatus(rawValue: value) ?? .scheduled
        }
    }

    private func configureEventForm() {
        addGuide(viewModel.mode.isNew
            ? "공통 정보를 먼저 등록하고, 이 행사에 날짜별 일정을 추가해 주세요. 행사만 저장하면 홈에 일정이 표시되지는 않아요."
            : "이 행사에 연결된 모든 일정에 공통 정보가 반영돼요. 일정별로 따로 설정한 값은 유지돼요.")
        titleField.input.text = viewModel.event.title
        venueField.input.text = viewModel.event.venueName
        descriptionField.input.text = viewModel.event.description
        reservationField.input.text = viewModel.event.reservationURL
        thumbnailField.input.text = viewModel.event.thumbnailURL
        stackView.addArrangedSubview(titleField)
        let types: [ScheduleType] = [
            .concert, .fanMeeting, .fanSigning, .musical, .festival, .broadcast,
            .liveStream, .release, .content, .event, .other
        ]
        configureMenu(
            title: "행사 유형",
            options: types.map { ($0.rawValue, $0.categoryName()) },
            selected: viewModel.event.type.rawValue
        ) { [weak self] value in
            self?.viewModel.event.type = ScheduleType(rawValue: value) ?? .event
        }
        [venueField, descriptionField, reservationField, thumbnailField].forEach(stackView.addArrangedSubview)
    }

    private func configureActions() {
        let fields = [titleField, nameField, urlField, venueField, reservationField, thumbnailField, zoneField]
        fields.forEach { field in
            field.input.addAction(UIAction { [weak self] _ in
                self?.hasChanges = true
            }, for: .editingChanged)
        }
        descriptionField.input.delegate = self
        [startPicker, endPicker, endToggle, allDayToggle].forEach { control in
            control.addAction(UIAction { [weak self] _ in
                guard let self else { return }
                hasChanges = true
                endPicker.isEnabled = endToggle.isOn
            }, for: .valueChanged)
        }
        saveButton.addAction(UIAction { [weak self] _ in
            self?.save()
        }, for: .touchUpInside)
    }

    func textViewDidChange(_ textView: UITextView) {
        hasChanges = true
    }

    private func save() {
        view.endEditing(true)
        switch viewModel.mode {
        case .newFeed, .editFeed:
            viewModel.feed.title = titleField.value
            viewModel.feed.description = descriptionField.value
            viewModel.feed.sourceName = nameField.value
            viewModel.feed.captureDate = startPicker.date
            viewModel.feed.permalink = urlField.value
            viewModel.feed.members = selectedMembers
        case .newSchedule, .editSchedule:
            viewModel.schedule?.startAt = startPicker.date
            viewModel.schedule?.endAt = endToggle.isOn ? endPicker.date : nil
            viewModel.schedule?.venueName = venueField.value
            viewModel.schedule?.isAllDay = allDayToggle.isOn
            viewModel.schedule?.timeZone = zoneField.value
        case .newEvent, .editEvent:
            viewModel.event.title = titleField.value
            viewModel.event.description = descriptionField.value
            viewModel.event.venueName = venueField.value
            viewModel.event.reservationURL = reservationField.value
            viewModel.event.thumbnailURL = thumbnailField.value
        }
        viewModel.save()
    }

    private func bind() {
        viewModel.onState = { [weak self] state in
            guard let self else { return }
            spinner.stopAnimating()
            scrollView.isHidden = false
            let isSaving: Bool
            switch state {
            case .checking:
                isSaving = true
                scrollView.isHidden = true
                spinner.startAnimating()
            case .editing:
                isSaving = false
            case .saving:
                isSaving = true
            }
            stackView.isUserInteractionEnabled = !isSaving && !isImporting && !viewModel.isSaveUnconfirmed
            saveButton.isEnabled = !isSaving && !isImporting && viewModel.isAuthorized
            navigationItem.leftBarButtonItem?.isEnabled = !isSaving
            navigationItem.rightBarButtonItem?.isEnabled = !isSaving && !isImporting && viewModel.isAuthorized && !viewModel.isSaveUnconfirmed
            saveButton.configuration?.showsActivityIndicator = isSaving
            saveButton.configuration?.title = viewModel.isDeleting ? "삭제 중…" : viewModel.isSaving ? "업로드·저장 중…" : viewModel.isSaveUnconfirmed ? "저장 결과 다시 확인" : "저장하기"
            navigationController?.tabBarController?.tabBar.isUserInteractionEnabled = !isSaving
        }
    }

    // MARK: - 파일 선택. 보안 범위의 원본은 편집기 전용 임시 폴더로 복사
    private func chooseFiles() {
        let types: [UTType] = [.jpeg, .png, .heic, .mpeg4Movie, UTType("org.webmproject.webp") ?? .image]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
        picker.allowsMultipleSelection = true
        picker.delegate = self
        present(picker, animated: true)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard !urls.isEmpty, urls.count <= 20 else {
            onMessage?("파일은 최대 20개 선택할 수 있어요.")
            return
        }
        setImporting(true)
        filesLabel.text = "선택한 파일을 준비하고 있어요…"

        Task { [weak self] in
            guard let self else { return }
            do {
                let result = try await Task.detached(priority: .userInitiated) {
                    try AdminMediaImporter.copy(urls)
                }.value
                importedDirectories.append(result.directory)
                try viewModel.appendFiles(result.files)
                hasChanges = true
            } catch {
                onMessage?((error as? AdminError)?.userMessage ?? "파일을 가져오지 못했어요. 다시 선택해 주세요.")
            }
            setImporting(false)
            renderMedia()
        }
    }

    private func choosePhotos() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 20
        configuration.selection = .ordered
        configuration.preferredAssetRepresentationMode = .compatible
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard !results.isEmpty else { return }
        setImporting(true)
        filesLabel.text = "사진을 준비하고 있어요. iCloud 사진은 시간이 걸릴 수 있어요…"
        Task { [weak self] in
            guard let self else { return }
            do {
                let imported = try await AdminPhotoImporter.copy(results)
                importedDirectories.append(contentsOf: imported.map(\.directory))
                try viewModel.appendFiles(imported.flatMap(\.files))
                hasChanges = true
            } catch {
                onMessage?((error as? AdminError)?.userMessage ?? "사진을 가져오지 못했어요. 다시 선택해 주세요.")
            }
            setImporting(false)
            renderMedia()
        }
    }

    private func setImporting(_ value: Bool) {
        isImporting = value
        stackView.isUserInteractionEnabled = !value && viewModel.isAuthorized && !viewModel.isSaving && !viewModel.isSaveUnconfirmed
        saveButton.isEnabled = !value && viewModel.isAuthorized && !viewModel.isSaving
        navigationItem.leftBarButtonItem?.isEnabled = !value && !viewModel.isSaving
        navigationItem.rightBarButtonItem?.isEnabled = !value && !viewModel.isSaving && viewModel.isAuthorized && !viewModel.isSaveUnconfirmed
    }

    private func renderMedia() {
        mediaStrip.configure(items: viewModel.previewItems, removedIDs: viewModel.mediaEdit.removedIDs)
        mediaStrip.isHidden = viewModel.previewItems.isEmpty
        let removed = viewModel.mediaEdit.removedIDs.count
        filesLabel.text = "기존 \(viewModel.mediaEdit.existing.count)개 · 추가 \(viewModel.selectedFiles.count)개 · 삭제 예정 \(removed)개\n사진을 누르면 크게 볼 수 있어요. 변경 사항은 저장 시 반영돼요."
    }

    // MARK: - 폼 구성 도우미
    private func addGuide(_ text: String) {
        stackView.addArrangedSubview(AdminStyle.label(text, style: .subheadline, color: .secondaryLabel))
    }

    private func addSectionTitle(_ text: String) {
        stackView.addArrangedSubview(AdminStyle.label(text, style: .headline))
    }

    private func addDatePicker(_ picker: UIDatePicker, title: String, date: Date) {
        addSectionTitle(title)
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale(identifier: "ko_KR")
        picker.date = date
        picker.accessibilityLabel = title
        stackView.addArrangedSubview(picker)
    }

    private func addToggle(_ toggle: UISwitch, title: String, isOn: Bool) {
        toggle.isOn = isOn
        toggle.onTintColor = AdminStyle.accent
        toggle.accessibilityLabel = title
        let row = UIStackView(arrangedSubviews: [AdminStyle.label(title, style: .body), toggle])
        row.alignment = .center
        row.spacing = 12
        stackView.addArrangedSubview(row)
    }

    private func configureMenu(title: String, options: [(String, String)], selected: String, onSelect: @escaping (String) -> Void) {
        addSectionTitle(title)
        let menuButton = AdminStyle.button("선택", symbol: "chevron.down", primary: false)
        menuButton.configuration?.title = options.first { $0.0 == selected }?.1
        menuButton.showsMenuAsPrimaryAction = true
        menuButton.menu = UIMenu(children: options.map { value, label in
            UIAction(title: label) { [weak self, weak menuButton] _ in
                menuButton?.configuration?.title = label
                self?.hasChanges = true
                onSelect(value)
            }
        })
        stackView.addArrangedSubview(menuButton)
    }
}

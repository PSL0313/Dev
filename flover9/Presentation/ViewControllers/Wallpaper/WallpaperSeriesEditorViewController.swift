//
//  WallpaperSeriesEditorViewController.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import ImageIO
import Kingfisher
import PhotosUI
import UIKit
import UniformTypeIdentifiers

// 시리즈 제목·제작자·분류·대표 이미지·공개 상태 편집 화면을 구성하고 사용자 동작을 연결합니다.
final class WallpaperSeriesEditorViewController: WallpaperEditorFormController {
    private let model: WallpaperSeriesEditorViewModel
    private let name = UITextField(), descriptionField = UITextField(), featured = UISwitch(), published = UISwitch()
    private let importer = WallpaperImageImporter()
    var onWallpapers: ((WallpaperSeriesEntity) -> Void)?
    init(series: WallpaperSeriesEntity?, manage: ManageWallpapersUseCase) {
        model = .init(series: series, manage: manage)
        super.init(style: .insetGrouped)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = model.existing == nil ? "새 시리즈" : "시리즈 편집"
        name.placeholder = "시리즈 제목"
        name.text = model.draft.title
        descriptionField.placeholder = "시리즈 소개"
        descriptionField.text = model.draft.description
        name.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                model.draft.title = name.text ?? ""
                model.hasChanges = true
            }, for: .editingChanged)
        descriptionField.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                model.draft.description = descriptionField.text ?? ""
                model.hasChanges = true
            }, for: .editingChanged)
        featured.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                model.draft.isFeatured = featured.isOn
                model.hasChanges = true
            }, for: .valueChanged)
        published.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                model.draft.isPublished = published.isOn
                model.hasChanges = true
            }, for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "저장",
            primaryAction: UIAction { [weak self] _ in
                self?.view.endEditing(true)
                self?.model.save()
            })
        dirty = { [weak self] in self?.model.hasChanges == true }
        busy = { [weak self] in self?.model.isSaving == true || self?.model.isUncertain == true }
        onClose = { [weak self] in self?.navigationController?.popViewController(animated: true) }
        model.onChange = { [weak self] in self?.render() }
        model.onError = { [weak self] in self?.wallpaperAlert($0) }
        model.onSaved = { [weak self] in self?.navigationController?.popViewController(animated: true) }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        model.load()
    }
    private func row(_ title: String, value: String? = nil) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = value
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    private func render() {
        if !model.hasChanges {
            name.text = model.draft.title
            descriptionField.text = model.draft.description
        }
        featured.isOn = model.draft.isFeatured
        published.isOn = model.draft.isPublished
        let creator =
            model.context?.creators.first { $0.id.lowercased() == model.draft.creatorID.uuidString.lowercased() }?.title
            ?? "불러오는 중…"
        formRows = [
            [
                fieldCell(name), fieldCell(descriptionField), row("크리에이터", value: creator),
                row("카테고리", value: model.draft.category.title),
            ],
            [
                row(
                    "대표 이미지",
                    value: model.draft.cover == nil
                        ? (model.existing?.coverURL == nil ? "선택" : "등록됨 · 교체") : "새 이미지 선택됨")
            ],
            [switchCell("공개", control: published)],
        ]
        if model.context?.canFeature == true { formRows[2].append(switchCell("추천 시리즈", control: featured)) }
        if model.existing != nil { formRows.append([row("배경화면 추가·수정")]) }
        headings = ["시리즈 정보", "대표 썸네일", "게시 설정", "배경화면"]
        footers = [
            nil, "JPEG·PNG·WebP, 최대 10MB. 새 이미지를 선택한 경우에만 업로드합니다.",
            "초안으로 저장한 뒤 배경화면을 추가하세요. 대표 이미지와 배경화면이 있어야 공개할 수 있습니다.", "시리즈 정보를 저장한 후 배경화면을 편집하세요.",
        ]
        let locked = model.isSaving || model.isUncertain || model.isLoading
        tableView.isUserInteractionEnabled = !locked
        navigationItem.leftBarButtonItem?.isEnabled = !model.isSaving && !model.isUncertain
        navigationItem.rightBarButtonItem?.title = model.isSaving ? "저장 중…" : model.isUncertain ? "결과 확인" : "저장"
        navigationItem.rightBarButtonItem?.isEnabled = !model.isSaving && !model.isLoading && model.context != nil
        tableView.reloadData()
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            importer.pick(from: self, cover: true) { [weak self] file in
                self?.model.draft.cover = file
                self?.model.hasChanges = true
                self?.render()
            }
            return
        }
        if indexPath.section == 3, let series = model.existing {
            guard !model.hasChanges else {
                wallpaperAlert("먼저 시리즈 변경 사항을 저장해 주세요.")
                return
            }
            onWallpapers?(series)
            return
        }
        guard indexPath.section == 0, indexPath.row >= 2 else { return }
        let category = indexPath.row == 3
        let choices =
            category
            ? WallpaperCategory.allCases.map { WallpaperChoice(id: $0.rawValue, title: $0.title) }
            : model.context?.creators ?? []
        let picker = WallpaperChoicePickerViewController(
            title: category ? "카테고리" : "크리에이터", options: choices,
            selected: [category ? model.draft.category.rawValue : model.draft.creatorID.uuidString])
        picker.onSelect = { [weak self] selection in
            guard let self, let value = selection.first else { return }
            if category, let category = WallpaperCategory(rawValue: value) {
                model.draft.category = category
            } else if let id = UUID(uuidString: value) {
                model.draft.creatorID = id
            }
            model.hasChanges = true
            render()
        }
        navigationController?.pushViewController(picker, animated: true)
    }
}

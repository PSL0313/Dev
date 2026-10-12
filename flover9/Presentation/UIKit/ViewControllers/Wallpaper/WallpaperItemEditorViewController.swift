//
//  WallpaperItemEditorViewController.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import ImageIO
import Kingfisher
import PhotosUI
import UIKit
import UniformTypeIdentifiers

// 개별 배경화면의 이미지·정렬 순서·연결 멤버 편집 화면을 구성하고 사용자 동작을 연결합니다.
final class WallpaperItemEditorViewController: WallpaperEditorFormController {
    private let model: WallpaperItemEditorViewModel
    private let order = UITextField()
    private let importer = WallpaperImageImporter()
    init(series: WallpaperSeriesEntity, wallpaper: WallpaperEntity?, manage: ManageWallpapersUseCase) {
        model = .init(series: series, wallpaper: wallpaper, manage: manage)
        super.init(style: .insetGrouped)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = model.existing == nil ? "배경화면 추가" : "배경화면 편집"
        order.placeholder = "정렬 순서"
        order.keyboardType = .numberPad
        order.text = String(model.draft.sortOrder)
        order.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                model.draft.sortOrder = Int(order.text ?? "") ?? -1
                model.hasChanges = true
            }, for: .editingChanged)
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
        model.load()
    }
    private func render() {
        func row(_ title: String, _ value: String) -> UITableViewCell {
            let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
            cell.textLabel?.text = title
            cell.detailTextLabel?.text = value
            cell.accessoryType = .disclosureIndicator
            return cell
        }
        let members =
            model.context?.members.filter { model.draft.memberCodes.contains($0.id) }.map(\.title).joined(
                separator: ", ") ?? ""
        formRows = [
            [fieldCell(order), row("멤버", members.isEmpty ? "선택" : members)],
            [
                row("썸네일·목업", model.draft.mockup != nil ? "새 이미지 선택됨" : model.existing == nil ? "선택" : "등록됨 · 교체"),
                row("다운로드 원본", model.draft.original != nil ? "새 이미지 선택됨" : model.existing == nil ? "선택" : "등록됨 · 교체"),
            ],
        ]
        headings = ["배경화면 정보", "이미지"]
        footers = [
            "여러 멤버를 선택할 수 있습니다. 정렬 순서는 0 이상의 숫자입니다.",
            "목업과 원본 각각 최대 50MB. JPEG·PNG·WebP를 지원하며 선택하지 않은 기존 이미지는 그대로 유지됩니다.",
        ]
        tableView.isUserInteractionEnabled = !model.isSaving && !model.isUncertain && !model.isLoading
        navigationItem.leftBarButtonItem?.isEnabled = !model.isSaving && !model.isUncertain
        navigationItem.rightBarButtonItem?.title = model.isSaving ? "저장 중…" : model.isUncertain ? "결과 확인" : "저장"
        navigationItem.rightBarButtonItem?.isEnabled = !model.isSaving && !model.isLoading && model.context != nil
        tableView.reloadData()
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            let original = indexPath.row == 1
            importer.pick(from: self) { [weak self] file in
                guard let self else { return }
                if original { model.draft.original = file } else { model.draft.mockup = file }
                model.hasChanges = true
                render()
            }
        } else if indexPath.row == 1 {
            let picker = WallpaperChoicePickerViewController(
                title: "멤버", options: model.context?.members ?? [], selected: Set(model.draft.memberCodes),
                multiple: true)
            picker.onSelect = { [weak self] selected in
                self?.model.draft.memberCodes = selected.sorted()
                self?.model.hasChanges = true
                self?.render()
            }
            navigationController?.pushViewController(picker, animated: true)
        }
    }
}

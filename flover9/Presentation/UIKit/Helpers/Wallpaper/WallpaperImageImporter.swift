//
//  WallpaperImageImporter.swift
//  flover9
//
//  Created by 박선린 on 9/28/26.
//

import ImageIO
import Kingfisher
import PhotosUI
import UIKit
import UniformTypeIdentifiers

/// Keeps the original bytes; importing a file never recompresses a downloadable wallpaper.
// 사진 또는 파일에서 이미지를 가져오고 형식과 용량을 확인합니다.
final class WallpaperImageImporter: NSObject, UIDocumentPickerDelegate, PHPickerViewControllerDelegate {
    weak var presenter: UIViewController?
    var completion: ((WallpaperImageFile) -> Void)?
    private var maximumBytes = 0
    func pick(from presenter: UIViewController, cover: Bool = false, completion: @escaping (WallpaperImageFile) -> Void) {
        self.presenter = presenter
        self.completion = completion
        maximumBytes = (cover ? 10 : 50) * 1_024 * 1_024
        let choices = UIAlertController(
            title: "이미지 선택", message: "JPEG·PNG·WebP 이미지를 선택해 주세요.", preferredStyle: .actionSheet)
        choices.addAction(
            UIAlertAction(title: "사진에서 선택", style: .default) { [weak self, weak presenter] _ in
                guard let self, let presenter else { return }
                var config = PHPickerConfiguration()
                config.filter = .images
                config.selectionLimit = 1
                config.preferredAssetRepresentationMode = .current
                let picker = PHPickerViewController(configuration: config)
                picker.delegate = self
                presenter.present(picker, animated: true)
            })
        choices.addAction(
            UIAlertAction(title: "파일에서 선택", style: .default) { [weak self, weak presenter] _ in
                guard let self, let presenter else { return }
                let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.jpeg, .png, .webP], asCopy: true)
                picker.delegate = self
                presenter.present(picker, animated: true)
            })
        choices.addAction(UIAlertAction(title: "취소", style: .cancel) { [weak self] _ in self?.completion = nil })
        choices.popoverPresentationController?.sourceView = presenter.view
        choices.popoverPresentationController?.sourceRect = CGRect(
            x: presenter.view.bounds.midX, y: presenter.view.bounds.midY, width: 1, height: 1)
        presenter.present(choices, animated: true)
    }
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        let access = url.startAccessingSecurityScopedResource()
        defer { if access { url.stopAccessingSecurityScopedResource() } }
        do {
            let size = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
            guard size > 0, size <= maximumBytes else {
                throw WallpaperError.validation("이미지 용량 제한은 \(maximumBytes / 1_024 / 1_024)MB입니다.")
            }
            let data = try Data(contentsOf: url)
            guard data.count <= maximumBytes, let source = CGImageSourceCreateWithData(data as CFData, nil),
                CGImageSourceGetCount(source) > 0,
                let type = CGImageSourceGetType(source) as String?, let mime = UTType(type)?.preferredMIMEType,
                ["image/jpeg", "image/png", "image/webp"].contains(mime)
            else { throw WallpaperError.validation("유효한 JPEG, PNG, WebP 이미지를 선택해 주세요.") }
            completion?(.init(data: data, contentType: mime))
        } catch { presenter?.wallpaperAlert(error.localizedDescription) }
        completion = nil
    }
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let result = results.first else {
            completion = nil
            return
        }
        let maximum = maximumBytes
        result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) {
            [weak self] url, error in
            let outcome: Result<Data, Error>
            do {
                if let error { throw error }
                guard let url else { throw WallpaperError.validation("사진을 불러오지 못했어요.") }
                let size = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
                guard size > 0 && size <= maximum else { throw WallpaperError.validation("이미지 용량 제한을 초과했습니다.") }
                outcome = .success(try Data(contentsOf: url))
            } catch { outcome = .failure(error) }
            Task { @MainActor [weak self] in
                guard let self else { return }
                defer { completion = nil }
                do {
                    let data = try outcome.get()
                    guard data.count <= maximum, let source = CGImageSourceCreateWithData(data as CFData, nil),
                        CGImageSourceGetCount(source) > 0,
                        let type = CGImageSourceGetType(source) as String?, let mime = UTType(type)?.preferredMIMEType,
                        ["image/jpeg", "image/png", "image/webp"].contains(mime)
                    else { throw WallpaperError.validation("JPEG·PNG·WebP 사진을 선택해 주세요. HEIC는 지원하지 않습니다.") }
                    completion?(.init(data: data, contentType: mime))
                } catch { presenter?.wallpaperAlert(error.localizedDescription) }
            }
        }
    }
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) { completion = nil }
}

//
//  UIImage++.swift
//  Flover9
//
//  Created by 박선린 on 5/14/26.
//
import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

extension UIImage {
    // UIImage의 SwiftUI Image 컴포넌트의 blur와 동일하게 처리해주는 메서드
    func makeBlurredImage(radius: Double) -> UIImage? {
        guard let inputImage = CIImage(image: self) else { return nil }

        let filter = CIFilter.gaussianBlur()
        filter.inputImage = inputImage
        filter.radius = Float(radius)

        guard let outputImage = filter.outputImage else { return nil }

        let context = CIContext()

        // 블러를 주면 이미지 바깥으로 번지기 때문에 원본 영역으로 잘라줌
        guard let cgImage = context.createCGImage(
            outputImage.cropped(to: inputImage.extent),
            from: inputImage.extent
        ) else { return nil }

        return UIImage(cgImage: cgImage, scale: self.scale, orientation: self.imageOrientation)
    }

    // UIImage의 평균 색상을 구하는 메서드
    func averageColor() -> UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }

        let filter = CIFilter.areaAverage()
        filter.inputImage = inputImage
        filter.extent = inputImage.extent

        guard let outputImage = filter.outputImage else { return nil }

        let context = CIContext(options: [.workingColorSpace: kCFNull as Any])
        var bitmap = [UInt8](repeating: 0, count: 4)

        context.render(
            outputImage,
            toBitmap: &bitmap,
            rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: nil
        )

        return UIColor(
            red: CGFloat(bitmap[0]) / 255,
            green: CGFloat(bitmap[1]) / 255,
            blue: CGFloat(bitmap[2]) / 255,
            alpha: CGFloat(bitmap[3]) / 255
        )
    }
}

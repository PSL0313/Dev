//
//  CustomPresentationController.swift
//  flover9
//
//  Created by 박선린 on 9/2/26.
//
import UIKit

final class CustomPresentationController: UIPresentationController {

    // 모달의 크기를 정하는 함수 -> containerView 값을 사용하여 계산할 수 있음
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView else {
            return .zero
        }

        return containerView.bounds // 컨테이너뷰 크기와 동일한 크기의 모달로 사용
    }
}

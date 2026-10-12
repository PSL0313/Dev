//
//  CustomTransitioningDelegate.swift
//  flover9
//
//  Created by 박선린 on 9/2/26.
//

import UIKit

/// 커스텀 Transition을 구성하는 각각의 객체를
/// UIViewController와 연결해주는 Delegate.
///
/// 각각의 책임은 아래와 같다.
///
/// CustomPresentationController
/// → 모달의 위치와 크기 결정
///
/// CustomPresentAnimator
/// → 모달이 나타나는 애니메이션
///
/// CustomDismissAnimator
/// → 모달이 사라지는 애니메이션
///
/// CustomInteractiveTransition
/// → 사용자의 Gesture와 Dismiss Animator의 진행도를 연결
///
/// `CustomTransitioningDelegate`는 위 객체들을 직접 실행하는 것이 아니라
/// UIKit이 필요한 객체를 요청할 때 적절한 객체를 반환하는 역할을 한다.
final class CustomTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {

    /// Dismiss 애니메이션을 담당하는 객체.
    private let dismissAnimator =
        CustomDismissAnimator()

    /// 사용자의 Pan Gesture를
    /// Dismiss 애니메이션 진행도와 연결하는 객체.
    private let interactiveTransition =
        CustomInteractiveTransition()

    /// 특정 Presented ViewController에
    /// Interactive Dismiss 기능을 연결한다.
    ///
    /// 외부에서는 CustomInteractiveTransition의 존재를 몰라도
    /// 이 메서드를 통해 Gesture를 연결할 수 있다.
    func attachInteraction(
        to viewController: UIViewController
    ) {
        /// iOS 18 버전을 지원하는 기기들 중 가장 작은 곡률은 39
        viewController.view.layer.cornerRadius = 39
        viewController.view.layer.cornerCurve = .continuous
        viewController.view.layer.masksToBounds = true
        interactiveTransition.attach(
            to: viewController
        )
    }

    /// UIKit이 커스텀 Presentation을 시작하면서
    /// 사용할 UIPresentationController를 요청할 때 호출한다.
    ///
    /// 여기서 반환하는 PresentationController가
    /// Presented View의 크기와 위치 등을 결정한다.
    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {

        // 현재 프로젝트에서 정의한
        // CustomPresentationController를 반환한다.
        //
        // presented:
        // 새롭게 표시될 ViewController
        //
        // presenting:
        // 해당 ViewController를 Present하는 기존 ViewController
        CustomPresentationController(
            presentedViewController: presented,
            presenting: presenting
        )
    }

    /// UIKit이 ViewController를 Dismiss할 때
    /// 어떤 Animator를 사용할지 요청하는 메서드.
    func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {

        // 위 → 아래 애니메이션을 구현한
        // CustomDismissAnimator를 반환한다.
        dismissAnimator
    }

    /// Dismiss Animator가 실행될 때
    /// Interactive Transition을 사용할지 UIKit이 확인하는 메서드.
    ///
    /// Animator:
    /// "0% → 100% 동안 View가 어떻게 움직이는가"
    ///
    /// InteractionController:
    /// "현재 그 애니메이션을 몇 %까지 진행할 것인가"
    ///
    /// 를 담당한다고 보면 된다.
    func interactionControllerForDismissal(
        using animator: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {

        // Gesture로 시작된 Dismiss라면
        // InteractiveTransition을 반환한다.
        //
        // 그러면 이후 update(), finish(), cancel()을 통해
        // 사용자의 손가락으로 Dismiss 애니메이션을 제어할 수 있다.
        //
        // 반대로 일반적인 dismiss(animated:) 호출이라면
        // nil을 반환해서 DismissAnimator가 자동으로 끝까지 실행되게 한다.
        interactiveTransition.isInteracting
            ? interactiveTransition
            : nil
    }
}

//
//  CustomInteractiveTransition.swift
//  flover9
//
//  Created by 박선린 on 9/2/26.
//
import UIKit

/// 사용자의 Pan Gesture와 Dismiss Transition의 진행도를 연결하는 객체.
///
/// `UIPercentDrivenInteractiveTransition`은
/// Transition 진행도를 0.0 ~ 1.0 사이의 값으로 직접 제어할 수 있게 해준다.
///
/// 예:
///
/// update(0.1) → Dismiss 애니메이션 10% 진행
/// update(0.5) → Dismiss 애니메이션 50% 진행
/// update(1.0) → Dismiss 애니메이션 100% 진행
///
/// 이 객체가 Pan Gesture의 이동 거리를 계산해서
/// 해당 값을 Dismiss Animator의 진행도로 전달한다.
final class CustomInteractiveTransition: UIPercentDrivenInteractiveTransition {

    /// 현재 Interactive Dismiss의 대상이 되는 ViewController.
    ///
    /// `weak`으로 선언하여
    /// InteractiveTransition 객체가 ViewController를 강하게 잡으면서
    /// 발생할 수 있는 불필요한 소유 관계를 만들지 않는다.
    private weak var presentedViewController: UIViewController?

    /// 현재 사용자가 직접 Dismiss Transition을 조작하고 있는지 나타낸다.
    ///
    /// true:
    /// Pan Gesture에 의해 Interactive Dismiss가 시작된 상태
    ///
    /// false:
    /// Interactive Dismiss가 진행 중이지 않은 상태
    ///
    /// `private(set)`이므로 외부에서는 값을 읽을 수 있지만
    /// 변경은 이 클래스 내부에서만 가능하다.
    private(set) var isInteracting = false

    /// 특정 ViewController에 Interactive Dismiss Gesture를 연결한다.
    ///
    /// - Parameter viewController:
    ///   Pan Gesture를 통해 Dismiss할 대상 ViewController
    func attach(to viewController: UIViewController) {

        // 나중에 Gesture가 시작됐을 때
        // 어떤 ViewController를 dismiss해야 하는지 알기 위해 저장한다.
        presentedViewController = viewController

        // 사용자의 수직 드래그 동작을 감지할 Pan Gesture 생성.
        //
        // Gesture는 viewController.view에 붙지만
        // 실제 Gesture 처리 로직의 주체는
        // CustomInteractiveTransition 자신이다.
        let panGesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(handlePanGesture(_:))
        )

        // 모달 전체 영역에서 Pan Gesture를 감지할 수 있도록
        // Presented ViewController의 View에 Gesture를 추가한다.
        viewController.view.addGestureRecognizer(panGesture)
    }

    /// Pan Gesture의 상태와 이동 거리를 확인하여
    /// Interactive Dismiss Transition을 제어한다.
    @objc
    private func handlePanGesture(
        _ gesture: UIPanGestureRecognizer
    ) {

        // Gesture가 연결되어 있는 View를 가져온다.
        //
        // 현재 구조에서는 CustomModalViewController의 root view다.
        guard let view = gesture.view else {
            return
        }

        // Gesture가 시작된 위치를 기준으로
        // 사용자의 손가락이 Y축으로 얼마나 이동했는지 계산한다.
        //
        // 아래 방향:
        // 양수
        //
        // 위 방향:
        // 음수
        let translationY =
            gesture.translation(in: view).y

        // 손가락이 화면 전체 높이 중
        // 몇 %만큼 아래로 움직였는지 계산한다.
        //
        // 예:
        //
        // 화면 높이 = 800
        // 아래로 이동 = 200
        //
        // 200 / 800 = 0.25
        //
        // 즉 Dismiss Transition을 25% 진행시킨다.
        //
        // min(1, ...)을 이용해서 최대값을 1로 제한하고,
        // max(0, ...)을 이용해서 최소값을 0으로 제한한다.
        //
        // 따라서 progress의 범위는 항상
        //
        // 0.0 ... 1.0
        //
        // 이 된다.
        let progress = max(
            0,
            min(
                1,
                translationY / view.bounds.height
            )
        )

        // Pan Gesture의 현재 상태에 따라
        // Interactive Transition을 처리한다.
        switch gesture.state {

        case .began:

            // 사용자가 손가락을 대고 드래그를 시작했다.
            //
            // 지금부터 발생하는 Dismiss는
            // 일반적인 자동 Dismiss가 아니라
            // 사용자가 직접 진행도를 조작하는
            // Interactive Dismiss라는 것을 표시한다.
            isInteracting = true

            // 실제 Dismiss Transition을 시작한다.
            //
            // 이 호출이 발생하면 UIKit은
            // CustomTransitioningDelegate에게
            //
            // 1. 어떤 Dismiss Animator를 사용할지
            // 2. InteractiveTransition을 사용할지
            //
            // 차례로 확인한다.
            presentedViewController?.dismiss(
                animated: true
            )

        case .changed:

            // 사용자가 손가락을 움직이고 있는 상태.
            //
            // 위에서 계산한 progress만큼
            // Dismiss Transition을 진행시킨다.
            //
            // 예:
            //
            // progress = 0.25
            //
            // → CustomDismissAnimator 애니메이션의
            //   약 25% 지점까지 진행
            update(progress)

        case .ended:

            // 사용자가 화면에서 손가락을 뗐다.
            isInteracting = false

            // 모달을 화면 높이의 15%보다 많이 내렸다면
            // Dismiss를 최종적으로 완료한다.
            if progress > 0.15 {

                // 남은 Dismiss 애니메이션을 끝까지 진행하고
                // ViewController를 실제로 dismiss한다.
                finish()

            } else {

                // 충분히 내리지 않았다면
                // 현재까지 진행했던 Dismiss를 취소하고
                // 모달을 원래 위치로 되돌린다.
                cancel()
            }

        case .cancelled:

            // 시스템 등의 이유로 Gesture 자체가 취소된 경우.
            isInteracting = false

            // 진행 중이던 Dismiss Transition 역시 취소하여
            // 모달을 원래 위치로 되돌린다.
            cancel()

        default:
            break
        }
    }
}

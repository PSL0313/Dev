//
//  CustomDismissAnimator.swift
//  flover9
//
//  Created by 박선린 on 9/2/26.
//
import UIKit

/// 모달이 Dismiss될 때 실행되는 애니메이션을 담당하는 객체.
///
/// PresentAnimator와 반대 방향의 애니메이션을 수행한다.
///
/// 현재 위치
///     ↓
/// 화면 아래
///
/// 즉, 화면 전체에 표시되어 있는 모달을
/// 아래쪽으로 내려서 사라지게 만든다.
final class CustomDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    /// Dismiss Transition의 전체 실행 시간을 반환한다.
    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {

        return 0.35
    }

    /// 실제 Dismiss 애니메이션을 정의한다.
    func animateTransition(
        using transitionContext: UIViewControllerContextTransitioning
    ) {

        // `.from`은 Transition이 시작될 때
        // 현재 화면에 표시되어 있는 View를 의미한다.
        //
        // Dismiss 상황에서는 현재 표시 중인
        // CustomModalViewController의 View가 된다.
        guard let fromView = transitionContext.view(forKey: .from) else {

            // Dismiss할 View를 가져오지 못했으므로
            // Transition 실패를 UIKit에 알려준다.
            transitionContext.completeTransition(false)

            return
        }

        // Transition이 진행되는 UIKit의 ContainerView.
        let containerView = transitionContext.containerView

        // 현재 모달의 Frame을 기준으로
        // ContainerView의 높이만큼 아래로 이동시킨 Frame을 만든다.
        //
        // 예:
        //
        // 현재
        // y = 0
        //
        // 화면 높이
        // 850
        //
        // 결과
        // y = 850
        //
        // 따라서 모달 전체가 화면 아래쪽으로 빠져나가게 된다.
        let finalFrame = fromView.frame.offsetBy(
            dx: 0,
            dy: containerView.bounds.height
        )

        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),

            animations: {

                // 현재 화면을 덮고 있는 모달을
                // 화면 아래쪽의 finalFrame으로 이동시킨다.
                fromView.frame = finalFrame
            },

            completion: { _ in

                // Interactive Transition에서는 사용자가
                // Dismiss 도중 취소(cancel)할 수도 있다.
                //
                // 따라서 UIView.animate 자체가 끝났다고 해서
                // 무조건 Dismiss가 완료된 것은 아니다.
                //
                // transitionWasCancelled가 false라면
                // 실제 Dismiss가 완료된 것이다.
                let completed =
                    !transitionContext.transitionWasCancelled

                // UIKit에게 최종 Transition 결과를 전달한다.
                //
                // true  → Dismiss 완료
                // false → Dismiss 취소
                transitionContext.completeTransition(completed)
            }
        )
    }
}

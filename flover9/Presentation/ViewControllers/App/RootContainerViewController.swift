//
//  RootContainerViewController.swift
//  flover9
//
//  Created by 박선린 on 7/27/26.
//

import UIKit


@MainActor
final class RootContainerViewController: UIViewController {
    private var launchViewController: LaunchViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func showLaunch(_ launchViewController: LaunchViewController) {
        self.launchViewController = launchViewController
        
        addChild(launchViewController)
        view.addSubview(launchViewController.view)
        
        launchViewController.view.frame = view.bounds
        launchViewController.view.autoresizingMask = [
            .flexibleWidth,
            .flexibleHeight
        ]
        
        launchViewController.didMove(toParent: self)
    }
    
    func installMainBehindLaunch(
        _ mainTabBarController: UITabBarController
    ) {
        addChild(mainTabBarController)
        
        // Launch 화면 아래에 삽입
        view.insertSubview(
            mainTabBarController.view,
            at: 0
        )
        
        mainTabBarController.view.frame = view.bounds
        mainTabBarController.view.autoresizingMask = [
            .flexibleWidth,
            .flexibleHeight
        ]
        
        mainTabBarController.didMove(toParent: self)
    }
    
    func dismissLaunch() {
        guard let launchViewController else { return }
        
        UIView.animate(
            withDuration: 0.6,
            animations: {
                launchViewController.view.transform =
                CGAffineTransform(
                    translationX: 0,
                    y: self.view.bounds.height
                )
            },
            completion: { _ in
                launchViewController.willMove(toParent: nil)
                launchViewController.view.removeFromSuperview()
                launchViewController.removeFromParent()
                
                self.launchViewController = nil
            }
        )
    }
    
    // 코디네이터에게 받은 뷰컨트롤러를 launchViewController에게 전달
    func showSignIn(signInViewController: SignInViewController) {
        launchViewController?.showSignIn(signInViewController: signInViewController)
    }
    
    func hideSignIn() {
        launchViewController?.hideSignIn()
    }
    
}

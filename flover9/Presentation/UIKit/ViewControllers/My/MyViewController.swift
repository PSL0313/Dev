//
//  MyViewController.swift
//  flover9
//
//  Created by 박선린 on 8/15/26.
//

import UIKit

class MyViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: MyViewModel

    // MARK: - Initializer
    init(viewModel: MyViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Deinit
    deinit { print("MyViewController deinit") }
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
    }
    

    private func setNavigationBar() {
        self.title = "MY"
        let settingButton = UIBarButtonItem(
            image: UIImage(systemName: "gearshape.fill"),
            style: .plain,
            target: self,
            action: #selector(showSetView)
        )
        self.navigationItem.rightBarButtonItem = settingButton
    }

}

private extension MyViewController {
    @objc func showSetView() {
        
    }
}

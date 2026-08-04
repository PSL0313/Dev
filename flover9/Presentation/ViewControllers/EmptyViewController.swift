//
//  EmptyViewController.swift
//  flover9
//
//  Created by 박선린 on 7/27/26.
//

import UIKit

@MainActor
class EmptyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = [.red, .blue, .green, .yellow, .orange].randomElement()
    }

}

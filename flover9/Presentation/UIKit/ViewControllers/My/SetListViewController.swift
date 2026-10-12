//
//  SetListViewController.swift
//  flover9
//
//  Created by 박선린 on 9/1/26.
//

import UIKit

// 설정 리스트
class SetListViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: SetListViewModel

    // MARK: - UI
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        return tv
    }()
    
    // MARK: - Initializer
    init(viewModel: SetListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

//
//  Coordinator.swift
//  flover9
//
//  Created by 박선린 on 9/24/26.
//

import UIKit

@MainActor
protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }

    func start()
}

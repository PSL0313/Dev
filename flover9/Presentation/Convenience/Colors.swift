//
//  Colors.swift
//  flover9
//
//  Created by 박선린 on 9/24/26.
//

import UIKit

enum Colors {
    enum Theme {
        static let mainBackground = UIColor(named: "mainBackgroundColor") ?? .systemBackground
        static let cardBackground = UIColor(named: "cardviewColor") ?? .secondarySystemBackground
        static let mainButton = UIColor(named: "mainButtonColor") ?? .systemGreen
    }

    enum Text {
        static let main = UIColor(named: "mainText") ?? .label
        static let reversed = UIColor(named: "reverseMainText") ?? .systemBackground
        static let additional = UIColor.secondaryLabel
    }

    enum Image {
        static let main = UIColor(named: "mainImageColor") ?? .label
        static let unselected = UIColor.systemGray
    }
}

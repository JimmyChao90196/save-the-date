//
//  SelectionModel.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/20.
//

import Foundation
import UIKit

@objc class SelectionButton: NSObject {
    var displayColor: UIColor
    var unselectedColor: UIColor
    var selectedColor: UIColor
    var title: String
    var font: UIFont
    
    init(displayColor: UIColor, unselectedColor: UIColor = .white, selectedColor: UIColor = .lightGray, title: String = "Placeholder", font: UIFont = .systemFont(ofSize: 18)) {
        self.displayColor = displayColor
        self.unselectedColor = unselectedColor
        self.selectedColor = selectedColor
        self.title = title
        self.font = font
    }
}

// Selection Data
let selectionsData: [SelectionButton] = [
    SelectionButton.init(displayColor: .white, unselectedColor: .black, title: "favorite"),
    SelectionButton.init(displayColor: .white, unselectedColor: .black, title: "My package"),
    SelectionButton.init(displayColor: .white, unselectedColor: .black, title: "draft")
]

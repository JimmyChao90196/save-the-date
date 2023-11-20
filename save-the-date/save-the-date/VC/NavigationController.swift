//
//  NavigationController.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/18.
//

import Foundation
import UIKit

class NavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.tintColor = .hexToUIColor(hex: "#3F3A3A")

        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundColor = .hexToUIColor(hex: "#FF4E4E")
        navBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.hexToUIColor(hex: "#FFFFFF"),
            .font: UIFont.systemFont(ofSize: 20, weight: .bold)
        ]
        navigationBar.standardAppearance = navBarAppearance
        navigationBar.scrollEdgeAppearance = navBarAppearance
    }
    
    /*
    func activateBadge() {
        tabBarItem.badgeColor = .init(hexcode: "845932")
        tabBarItem.badgeValue = "\(CartItem.myCart.count)"
    }*/
}

//
//  TabbarController.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/18.
//

import Foundation
import UIKit

class TabbarController: UITabBarController, UITabBarControllerDelegate {
    
    enum Tab: String {
        case explorePackage = "Explore"
        case createPackage = "Create Package"
        case chat = "Chat"
        case profile = "Profile"
    }
    
    let tabs: [Tab] = [.explorePackage, .createPackage, .chat, .profile]
    
    // MARK: View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        let tabBarApearance = UITabBarAppearance()
        tabBarApearance.backgroundColor = .white
        tabBar.scrollEdgeAppearance = tabBarApearance
        tabBar.standardAppearance = tabBarApearance
        tabBar.tintColor = .hexToUIColor(hex: "#3F3A3A")
        
        viewControllers = tabs.map { tab in
            let viewController: UIViewController = {
                switch tab {
                case .explorePackage: return ExplorePackageViewController()
                case .createPackage: return CreatePackageViewController()
                case .chat: return ChatViewController()
                case .profile: return ProfileViewController()
                }
            }()
            
            viewController.title = tab.rawValue
            let nav = NavigationController(rootViewController: viewController)
            
            // Save for latter use
            // if tab == .catalog {
            // nav.navigationBar.standardAppearance.shadowColor = .clear
            // nav.navigationBar.scrollEdgeAppearance?.shadowColor = .clear}
            // if tab == .cart { nav.activateBadge() }
            
            switch tab {
            case .explorePackage:
                nav.tabBarItem.image = UIImage(systemName: "safari")
                nav.tabBarItem.selectedImage = UIImage(systemName: "safari.fill")
            case .createPackage:
                nav.tabBarItem.image = UIImage(systemName: "pencil.tip.crop.circle.badge.plus")
                nav.tabBarItem.selectedImage = UIImage(systemName: "pencil.tip.crop.circle.badge.plus.fill")
            case .chat:
                nav.tabBarItem.image = UIImage(systemName: "message")
                nav.tabBarItem.selectedImage = UIImage(systemName: "message.fill")
            case .profile:
                nav.tabBarItem.image = UIImage(systemName: "person")
                nav.tabBarItem.selectedImage = UIImage(systemName: "person.fill")
            }
            
            // Save for latter use
//            nav.tabBarItem.image = UIImage(named: "Icons_36px_\(tab.rawValue)_Normal")
//            nav.tabBarItem.selectedImage = UIImage(named: "Icons_36px_\(tab.rawValue)_Selected")
//            nav.tabBarItem.imageInsets = UIEdgeInsets(top: 7,left: 0,bottom: -7,right: 0)

            return nav
        }
    }
}

//
//  TabbarController.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/18.
//

import Foundation
import UIKit

class TabbarController: UITabBarController, UITabBarControllerDelegate {
    
    // Pending deepLink
    var pendingDeepLink: URL?
    
    // Credential pack
    var userCredentialsPack = UserCredentialsPack(
        name: "",
        email: "",
        uid: "",
        token: nil)
    
    enum Tab: String {
        case explorePackage = "Explore"
        case createPackage = "Create Package"
        case chat = "Chat"
        case profile = "Profile"
    }
    
    let tabs: [Tab] = [.explorePackage,
                       .createPackage,
                       .chat,
                       .profile]
    
    // MARK: View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add observer
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCredentialsUpdate(notification:)),
            name: .userCredentialsUpdated,
            object: nil)
        
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
            
            switch tab {
            case .explorePackage:
                nav.tabBarItem.tag = 0
                nav.tabBarItem.image = UIImage(systemName: "safari")
                nav.tabBarItem.selectedImage = UIImage(systemName: "safari.fill")
            case .createPackage:
                nav.tabBarItem.tag = 1
                nav.tabBarItem.image = UIImage(systemName: "pencil.tip.crop.circle.badge.plus")
                nav.tabBarItem.selectedImage = UIImage(systemName: "pencil.tip.crop.circle.badge.plus.fill")
            case .chat:
                nav.tabBarItem.tag = 2
                nav.tabBarItem.image = UIImage(systemName: "message")
                nav.tabBarItem.selectedImage = UIImage(systemName: "message.fill")
            case .profile:
                nav.tabBarItem.tag = 3
                nav.tabBarItem.image = UIImage(systemName: "person")
                nav.tabBarItem.selectedImage = UIImage(systemName: "person.fill")
            }
            
            return nav
        }
    }
    
    // MARK: - Additional method -
    
    @objc func handleCredentialsUpdate(notification: Notification) {
        if let credentials = notification.object as? UserCredentialsPack {
            // Handle the credentials update
            print("Received new credentials: \(credentials)")
            
            self.userCredentialsPack = credentials
        }
    }
    
    // MARK: - Delegate method -
    func tabBarController(
        _ tabBarController: UITabBarController,
        shouldSelect viewController: UIViewController) -> Bool {
            
            // Print the view controller for debugging purposes
            guard let nvc = viewController as? UINavigationController else { return false }
            
            switch nvc.tabBarItem.tag {
                
            case 0:
                
                return true
                
            default:
                
                let token = self.userCredentialsPack.token
                
                if token == nil || token == "" {
                    
                    let loginVC = LoginViewController()
                    loginVC.modalPresentationStyle = .automatic
                    loginVC.modalTransitionStyle = .coverVertical
                    loginVC.enteringKind = .create
                    loginVC.sheetPresentationController?.detents = [.custom(resolver: { context in
                        context.maximumDetentValue * 0.35
                    })]
                    
                    nvc.present(loginVC, animated: true)
                    
                    return false
                    
                } else {
                    
                    return true
                }
            }
        }
}

//
//  TabbarController.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/18.
//

import Foundation
import UIKit

class TabbarController: UITabBarController, UITabBarControllerDelegate {
    
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
            
            // Save for later use
            // if tab == .catalog {
            // nav.navigationBar.standardAppearance.shadowColor = .clear
            // nav.navigationBar.scrollEdgeAppearance?.shadowColor = .clear}
            // if tab == .cart { nav.activateBadge() }
            
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
        
        // Process any pending deep link
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
           let deepLinkURL = appDelegate.pendingDeepLink {
            appDelegate.pendingDeepLink = nil // Clear the pending deep link
            handleDeepLink(url: deepLinkURL)
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

extension TabbarController {

    func handleDeepLink(url: URL) {
        // Parse the URL to get the necessary information
        // Example: Extracting a session ID for a "joinSession" action
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems,
              let sessionId = queryItems.first(where: { $0.name == "id" })?.value else {
            print("Invalid deep link URL")
            return
        }
        
        // Determine which tab to switch to based on the deep link
        let targetTabIndex = 1 // Change this index based on your app's tabs

        // Ensure the tabIndex is within the bounds of your view controllers
        guard targetTabIndex < self.viewControllers?.count ?? 0 else {
            print("Invalid tab index")
            return
        }

        // Switch to the specified tab
        self.selectedIndex = targetTabIndex

        // Get the navigation controller for that tab
        if let navController = self.viewControllers?[targetTabIndex] as? UINavigationController {
            // Clear any existing view controllers on the stack if necessary
            navController.popToRootViewController(animated: false)

            // Create an instance of MultiUserViewController and set its properties
            let multiUserVC = MultiUserViewController()
            multiUserVC.documentPath = sessionId // or any other property you need to set

            // Push the MultiUserViewController onto the navigation stack
            navController.pushViewController(multiUserVC, animated: true)
        }
    }
}

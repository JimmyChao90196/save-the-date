//
//  SceneDelegate.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/15.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var pendingDeepLink: URL?
    var test: Int?
    
    // static let shared = UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions) {
            
            guard let scene = (scene as? UIWindowScene) else { return }
            
            let tabBarController = TabbarController()
           
            LKProgressHUD.shared.view = tabBarController.view
            
            // deeplink Open
            if connectionOptions.urlContexts.first?.url != nil {
              let urlinfo = connectionOptions.urlContexts.first?.url
                
                if urlinfo?.scheme == "saveTheDate" {
                    
                    pendingDeepLink = urlinfo
                    tabBarController.pendingDeepLink = urlinfo
                }
            }
            
            // let tabBarController = TabbarController()
            window = UIWindow(windowScene: scene)
            window!.rootViewController = tabBarController
            window!.makeKeyAndVisible()
            
            // Pass value directly
            if let tabbarController = self.window?.rootViewController as? UITabBarController,
               let navigationController = tabbarController.viewControllers?.first as? UINavigationController,
               let desiredController = navigationController.viewControllers.first as? ExplorePackageViewController {
                   desiredController.url = pendingDeepLink
            }
        }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    // Universial link Open when app is onPause
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let urlinfo = userActivity.webpageURL {
            
            print("Universial Link Open at SceneDelegate on App Pause  ::::::: \(urlinfo)")
            if urlinfo.scheme == "saveTheDate" {
                
                // fatalError()

                pendingDeepLink = urlinfo
            }
            
        }
    }
    
    // Other methods...
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let urlContext = URLContexts.first else { return }
        
        let url = urlContext.url
        
        // Handle deep link
        if url.scheme == "saveTheDate" {
            
            // fatalError()

            pendingDeepLink = url
        }
    }
}

extension Notification.Name {
    static let deepLinkOpened = Notification.Name("DeepLinkOpenedNotification")
}

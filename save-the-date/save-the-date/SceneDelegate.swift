//
//  SceneDelegate.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/15.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    // swiftlint: disable force_cast
    static let shared = UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate
    
    var window: UIWindow?
    var pendingDeepLink: URL?
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions) {
            
            guard let scene = (scene as? UIWindowScene) else { return }
            
            // deeplink Open
            if connectionOptions.urlContexts.first?.url != nil {
              let urlinfo = connectionOptions.urlContexts.first?.url
                
                print ("Deeplink Open at SceneDelegate on App Start ::::::: \(String(describing: urlinfo))")
                if urlinfo?.scheme == "saveTheDate" {
                    
                    pendingDeepLink = urlinfo
                    
                    let tabBarController = TabbarController()
                    tabBarController.pendingDeepLink = urlinfo
                    window = UIWindow(windowScene: scene)
                    window!.rootViewController = tabBarController
                    window!.makeKeyAndVisible()
                }
            }
            
            let tabBarController = TabbarController()
            window = UIWindow(windowScene: scene)
            window!.rootViewController = tabBarController
            window!.makeKeyAndVisible()
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

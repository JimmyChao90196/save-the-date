//
//  AppDelegate.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/15.
//

import UIKit
import GooglePlaces
import GoogleMaps
import FirebaseCore
import Firebase
import FirebaseFirestoreSwift
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var pendingDeepLink: URL?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            // Override point for customization after application launch.
            
            GMSPlacesClient.provideAPIKey("AIzaSyDKpRUS5pK0qBRxosBaXhazzsyWING1GxY")
            GMSServices.provideAPIKey("AIzaSyDKpRUS5pK0qBRxosBaXhazzsyWING1GxY")
            
            FirebaseApp.configure()
            
//            if let launchUrlString = ProcessInfo.processInfo.environment["LAUNCH_URL"],
//               let url = URL(string: launchUrlString) {
//                
//                // Check for a deep link
//                
//                pendingDeepLink = url
//            }
            
            // Check for a deep link
            if let url = launchOptions?[.url] as? URL {
                pendingDeepLink = url
            }
            
            return true
        }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
    }
}

// MARK: - Notification -
extension Notification.Name {
    static let joinSessionNotification = Notification.Name("joinSessionNotification")
}

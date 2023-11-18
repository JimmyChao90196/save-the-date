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

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            // Override point for customization after application launch.
            
            GMSPlacesClient.provideAPIKey("AIzaSyDKpRUS5pK0qBRxosBaXhazzsyWING1GxY")
            GMSServices.provideAPIKey("AIzaSyDKpRUS5pK0qBRxosBaXhazzsyWING1GxY")
            
            FirebaseApp.configure()
            
            return true
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

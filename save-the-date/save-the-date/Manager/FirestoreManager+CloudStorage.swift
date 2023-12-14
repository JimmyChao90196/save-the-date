//
//  FirestoreManager+CloudStorage.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/12/14.
//

import Foundation
import UIKit
import FirebaseCore
import FirebaseFirestoreSwift
import FirebaseStorage
import FirebaseAuth

extension FirestoreManager {
    
    // MARK: - Downloading the url
    func fetchStorageURL(storagePath path: String) {
        
        let storageRef = storage.reference().child(path)
        
        storageRef.downloadURL { fetchedURL, error in
            guard let url = fetchedURL, error == nil else { return }
            
            let urlString = url.absoluteString
            print("Download \(urlString)")
            
            UserDefaults.standard.set(urlString, forKey: "url")
        }
    }
    
    // MARK: - Uploading the data
    func uploadStoragePhoto(targetImage: UIImage, userId: String) {
        
        // Create a root reference
        let path = "userProfile/\(userId).png"
        let storageRef = storage.reference().child(path)
        
        guard let imageData = targetImage.pngData() else { return }
        
        storageRef.putData(imageData, metadata: nil) { _, error in
            guard error == nil else {
                print("Failed to upload")
                return
            }
            
            self.fetchStorageURL(storagePath: path)
        }
    }
}

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

enum ImageType {
    case profileImage
    case profileCover
}

enum UploadDownloadImageError: Error {
    case userImageURLNotFound
    case uploadFaild
}

extension FirestoreManager {
    
    // MARK: - Downloading the url
    func fetchStorageURL(
        storagePath path: String,
        completion: @escaping (Result<String, Error>) -> Void) {
            
            let storageRef = storage.reference().child(path)
            
            storageRef.downloadURL { fetchedURL, error in
                guard let url = fetchedURL, error == nil else {
                    completion(.failure( UploadDownloadImageError.userImageURLNotFound ))
                    return
                }
                
                let urlString = url.absoluteString
                print("Download \(urlString)")
                completion(.success(urlString))
                
                UserDefaults.standard.set(urlString, forKey: "url")
            }
        }
    
    // MARK: - Uploading the data
    func uploadStoragePhoto(
        type: ImageType,
        targetImage: UIImage,
        userId: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        
        // Create a root reference
        var path = "userProfile/\(userId).png"
        
        switch type {
        case .profileImage: path = "userProfile/\(userId).png"
        case .profileCover: path = "userCover/\(userId).png"
        }
        
        let storageRef = storage.reference().child(path)
        
        guard let imageData = targetImage.pngData() else { return }
        
        storageRef.putData(imageData, metadata: nil) { _, error in
            guard error == nil else {
                print("Failed to upload")
                completion(.failure(UploadDownloadImageError.uploadFaild))
                return
            }
            
            self.fetchStorageURL(storagePath: path) { result in
                    switch result {
                    case .success(let url):
                        completion(.success(url))
                        
                    case .failure(let error):
                        completion(.failure(error))
                        
                    }
                }
        }
    }
}

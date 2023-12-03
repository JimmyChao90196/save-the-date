//
//  UserManager.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/12/2.
//

import Foundation
import UIKit

class UserManager {
    static let shared = UserManager()
    var currentUser = User()
    var userProfileImage: UIImage?
    
    // Fetch user photo
    func downloadImage( completion: @escaping (Result<UIImage?, Error>) -> Void) {
        
        guard let url = URL(string: currentUser.photoURL) else { return }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(FetchedError.userImageNotFound))
                return
            }
            
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                completion(.success(image))
                
                self.userProfileImage = image
            }
        }
        
        // Resume the task
        task.resume()
    }
}

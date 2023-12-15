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

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(FetchedError.userImageNotFound))
                return
            }
            
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                completion(.success(image))
                
            }
        }
        
        // Resume the task
        task.resume()
    }
    
    // Fetch user photo
    func downloadImage(
        urlString: String,
        completion: @escaping (Result<UIImage?, Error>) -> Void) {
        
        guard let url = URL(string: urlString) else { return }

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(FetchedError.userImageNotFound))
                return
            }
            
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                completion(.success(image))
                
            }
        }
        
        // Resume the task
        task.resume()
    }
    
    // download images
    func downloadImages(from urlStrings: [String], completion: @escaping (Result<[UIImage], Error>) -> Void) {
        var images: [UIImage] = []
        let dispatchGroup = DispatchGroup()

        var encounteredError: Error?

        for urlString in urlStrings {
            
            if urlString.isEmpty {
                images.append(UIImage(systemName: "person.circle")!)
                continue
            }

            guard let url = URL(string: urlString) else { continue }

            dispatchGroup.enter()
            URLSession.shared.dataTask(with: url) { data, _, error in
                defer { dispatchGroup.leave() }

                if let error = error {
                    print("Error downloading image: \(error)")
                    encounteredError = error
                    return
                }

                if let data = data, let image = UIImage(data: data) {
                    images.append(image)
                }
            }.resume()
        }

        dispatchGroup.notify(queue: .main) {
            if let error = encounteredError {
                completion(.failure(error))
            } else {
                completion(.success(images))
            }
        }
    }
    
    // download images
    func downloadImagesToDic(
        from urlStrings: [String],
        completion: @escaping (Result<[String: UIImage], Error>) -> Void) {
        var imagesDic: [String: UIImage] = [:]
        let dispatchGroup = DispatchGroup()

        var encounteredError: Error?

        for urlString in urlStrings {
            
            if urlString.isEmpty {
                imagesDic[""] = UIImage(systemName: "person.circle")!
                continue
            }

            guard let url = URL(string: urlString) else { continue }

            dispatchGroup.enter()
            URLSession.shared.dataTask(with: url) { data, _, error in
                defer { dispatchGroup.leave() }

                if let error = error {
                    print("Error downloading image: \(error)")
                    encounteredError = error
                    return
                }

                if let data = data, let image = UIImage(data: data) {
                    imagesDic[urlString] = image
                    // images.append(image)
                }
            }.resume()
        }

        dispatchGroup.notify(queue: .main) {
            if let error = encounteredError {
                completion(.failure(error))
            } else {
                completion(.success(imagesDic))
            }
        }
    }
}

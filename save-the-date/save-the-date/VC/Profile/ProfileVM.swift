//
//  ProfileVM.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/12/2.
//

import Foundation
import UIKit
import SnapKit

import FirebaseStorage
import FirebaseCore
import FirebaseFirestoreSwift

import ImageIO

class ProfileViewModel {
    
    let firestoreManager = FirestoreManager.shared
    let userManager = UserManager.shared
    
    var currentPackages = Box<[Package]>([])
    var currentProfileImages = Box<[UIImage]>([])
    
    var favPackages = Box<[Package]>([])
    var pubPackages = Box<[Package]>([])
    var draftPackages = Box<[Package]>([])
    
    var favProfileImages = Box<[UIImage]>([])
    var pubProfileImages = Box<[UIImage]>([])
    var draftProfileImages = Box<[UIImage]>([])
    
    var currentUser = Box(User())
    var profileImage = Box(UIImage())
    var profileCoverImage = Box(UIImage())
    
    // Should dismiss or not
    func shouldDismiss(list: [WaitingList: Bool]) {
        var copyList = list.enumerated()
        
        copyList.forEach { _, element in
            if element.value == false {
                return
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            LKProgressHUD.dismiss()
        }
    }
    
    // Check user
    func checkIfUserExist(by user: User) {
        
        if user.uid == "none" || user.uid == "" {
            return
        }
        
        firestoreManager.checkUser(by: user) { result in
            
            switch result {
            case .success(let users): print("fetched users: \(users)")
                self.currentUser.value = users.first ?? User()
                
            case .failure(let error): print("\(error), create new user instead")
                self.currentUser.value = user
                
                self.firestoreManager.addUserWithJson(
                    User(name: user.name,
                         email: user.email,
                         photoURL: user.photoURL,
                         uid: user.uid)) {}
            }
        }
    }
    
    // Fetch user
    func fetchCurrentUser( _ userId: String) {

        Task {
            do {
                let user = try await firestoreManager.fetchUser( userId )
                self.currentUser.value = user
                
            } catch {
            
                print(error)
            }
        }
    }
    
    func updateUserName(_ name: String) {
        
        firestoreManager.updateUserName(
            userId: self.userManager.currentUser.uid,
            newName: name) {}
    }
    
    // Upload to firebase storage
    func uploadImages(
        type: ImageType,
        targetImage: UIImage) {
            
            self.firestoreManager.uploadStoragePhoto(
                type: type,
                targetImage: targetImage,
                userId: self.userManager.currentUser.uid) { result in
                    switch result {
                    case .success(let url):
                        print(String(describing: url))
                        
                        self.firestoreManager.updateUserPhoto(
                            userId: self.userManager.currentUser.uid,
                            imageUrl: url,
                            type: type) {}
                        
                    case .failure(let error):
                        print(error)
                    }
                }
        }
    
    // Fetch user photos
    func fetchUserProfileImage() {
        userManager.downloadImage { result in
            switch result {
            case .success(let image):
                print(image as Any)
                self.profileImage.value = image ?? UIImage()
                
            case .failure(let error):
                print(error)
                // Return a default image instead
                self.profileImage.value = UIImage(systemName: "person.circle")!
            }
        }
    }
    
    func fetchProfileCoverImage(with urlString: String) {
        
        userManager.downloadImage(urlString: urlString) { result in
            switch result {
            case .success(let image):
                print(image as Any)
                
                self.profileCoverImage.value = image ??
                UIImage(resource: .placeholder01)
                
            case .failure(let error):
                print(error)
                // Return a default image instead
                self.profileCoverImage.value = UIImage(resource: .placeholder01)
            }
        }
    }
    
    // Fetch user profile images
    func fetchUserProfileImages(
        from packages: [Package],
        with state: PackageState) {
            
        let urls = packages.map { $0.photoURL }
        
        self.userManager.downloadImages(from: urls, completion: { result in
            switch result {
            case .success(let images):
                switch state {
                case .publishedState: self.pubProfileImages.value = images
                    self.currentProfileImages.value = images
                    
                case .favoriteState: self.favProfileImages.value = images
                    self.currentProfileImages.value = images
                    
                case .draftState: self.draftProfileImages.value = images
                    self.currentProfileImages.value = images
                    
                default: self.favProfileImages.value = images
                    self.currentProfileImages.value = images
                }
                
            case .failure(let error):
                print(error)
            }
        })
    }
    
    // Calculate aspect ratio
    func calculateAspectRatioSize(for image: UIImage, maxWidth: CGFloat, maxHeight: CGFloat) -> CGSize {
        let aspectRatio = image.size.width / image.size.height

        var targetWidth = maxWidth
        var targetHeight = targetWidth / aspectRatio

        if targetHeight > maxHeight {
            targetHeight = maxHeight
            targetWidth = targetHeight * aspectRatio
        }

        return CGSize(width: targetWidth, height: targetHeight)
    }
    
    // Down sampling
    func downsample(
        image: UIImage,
        to pointSize: CGSize,
        scale: CGFloat = UIScreen.main.scale,
        completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let imageData = image.jpegData(compressionQuality: 1.0) ?? image.pngData() else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            let options: [CFString: Any] = [
                kCGImageSourceShouldCache: false,
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceThumbnailMaxPixelSize: max(pointSize.width, pointSize.height) * scale
            ]

            guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, nil),
                  let downsampledImage = CGImageSourceCreateThumbnailAtIndex(
                    imageSource,
                    0,
                    options as CFDictionary) else {
                
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            let processedImage = UIImage(cgImage: downsampledImage)
            DispatchQueue.main.async {
                completion(processedImage)
            }
        }
    }
    
    // Fetch packages
    func fetchPackages(with state: PackageState) {
        Task {
            do {
                switch state {
                    
                case .publishedState:
                    let targetIDs = currentUser.value.publishedPackages
                    
                    // Fetch packages
                    self.pubPackages.value = try await firestoreManager.fetchPackages(
                        withIDs: targetIDs)
                    
                    self.pubPackages.value = self.pubPackages.value.sorted {
                        $0.info.title < $1.info.title }
                    self.currentPackages.value = self.pubPackages.value
                    
                    // Fetch profilePicture
                    fetchUserProfileImages(from: self.pubPackages.value, with: .publishedState)
                    
                case .favoriteState:
                    let targetIDs = currentUser.value.favoritePackages
                    
                    // Fetch packages
                    self.favPackages.value = try await firestoreManager.fetchPackages(
                        withIDs: targetIDs)
                    
                    self.favPackages.value = self.favPackages.value.sorted {
                        $0.info.title < $1.info.title }
                    self.currentPackages.value = self.favPackages.value
                    
                    // Fetch profilePicture
                    fetchUserProfileImages(from: self.favPackages.value, with: .favoriteState)
                    
                case .draftState:
                    let targetIDs = currentUser.value.draftPackages
                    
                    // Fetch packages
                    self.draftPackages.value = try await firestoreManager.fetchPackages(
                        withIDs: targetIDs)
                    
                    self.draftPackages.value = self.draftPackages.value.sorted {
                        $0.info.title < $1.info.title }
                    self.currentPackages.value = self.draftPackages.value
                    
                    // Fetch profilePicture
                    fetchUserProfileImages(from: self.draftPackages.value, with: .draftState)
                    
                default: return
                    
                }
                
            } catch {
                print("Error occurred: \(error)")
            }
        }
    }
}

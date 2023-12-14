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

class ProfileViewModel {
    
    let firestoreManager = FirestoreManager.shared
    let userManager = UserManager.shared
    
    var favPackages = Box<[Package]>([])
    var pubPackages = Box<[Package]>([])
    var draftPackages = Box<[Package]>([])
    
    var favProfileImages = Box<[UIImage]>([])
    var pubProfileImages = Box<[UIImage]>([])
    var draftProfileImages = Box<[UIImage]>([])
    
    var currentUser = Box(User())
    var profileImage = Box(UIImage())
    
    // Check user
    func checkIfUserExist(by user: User) {
        
        /*
        if user.email == "jimmy@gmail.com" || user.email == "none" || user.email == "" {
            return
        }
        */
        
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
                case .favoriteState: self.favProfileImages.value = images
                case .draftState: self.draftProfileImages.value = images
                default: self.favProfileImages.value = images
                }
                
            case .failure(let error):
                print(error)
            }
        })
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
                    
                    // Fetch profilePicture
                    fetchUserProfileImages(from: self.pubPackages.value, with: .publishedState)
                    
                case .favoriteState:
                    let targetIDs = currentUser.value.favoritePackages
                    
                    // Fetch packages
                    self.favPackages.value = try await firestoreManager.fetchPackages(
                        withIDs: targetIDs)
                    
                    self.favPackages.value = self.favPackages.value.sorted {
                        $0.info.title < $1.info.title }
                    
                    // Fetch profilePicture
                    fetchUserProfileImages(from: self.favPackages.value, with: .favoriteState)
                    
                case .draftState:
                    let targetIDs = currentUser.value.draftPackages
                    
                    // Fetch packages
                    self.draftPackages.value = try await firestoreManager.fetchPackages(
                        withIDs: targetIDs)
                    
                    self.draftPackages.value = self.draftPackages.value.sorted {
                        $0.info.title < $1.info.title }
                    
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

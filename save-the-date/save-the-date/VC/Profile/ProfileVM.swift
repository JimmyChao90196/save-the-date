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
    
    var currentUser = Box(User())
    var profileImage = Box(UIImage())
    
    // Check user
    func checkIfUserExist(by user: User) {
        
        if user.email == "jimmy@gmail.com" || user.email == "none" || user.email == "" {
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
    func fetchCurrentUser( _ userEmail: String) {

        Task {
            do {
                let user = try await firestoreManager.fetchUser( userEmail )
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
                    
                    self.pubPackages.value = try await firestoreManager.fetchPackages(
                        withIDs: targetIDs)
                    
                case .favoriteState:
                    let targetIDs = currentUser.value.favoritePackages
                    
                    self.favPackages.value = try await firestoreManager.fetchPackages(
                        withIDs: targetIDs)
                    
                case .draftState:
                    let targetIDs = currentUser.value.draftPackages
                    
                    self.draftPackages.value = try await firestoreManager.fetchPackages(
                        withIDs: targetIDs)
                    
                default: return
                    
                }
                
            } catch {
                print("Error occurred: \(error)")
            }
        }
    }
}

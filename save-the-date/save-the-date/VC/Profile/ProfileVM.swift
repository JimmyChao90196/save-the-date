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
    
    var currentUser = Box(User())
    
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
}

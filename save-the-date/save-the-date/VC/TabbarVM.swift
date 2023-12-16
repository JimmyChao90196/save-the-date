//
//  TabbarVM.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/12/16.
//

import Foundation
import UIKit
import GoogleSignIn

import FirebaseCore
import FirebaseAuthInterop
import FirebaseAuth

import AuthenticationServices
import CryptoKit

class TabbarViewModel {
    
    let firestoreManager = FirestoreManager.shared
    var userManager = UserManager.shared
    
    var userInfo = Box(User())
    var userCredentialPack = Box(
        UserCredentialsPack(
            name: "",
            email: "",
            uid: "",
            token: nil))
    
    // Check sign in
    func checkSignIn() {
        if let user = Auth.auth().currentUser {
            
            let uid = user.uid
            let email = user.email
            let photoURL = user.photoURL?.absoluteString
            let name = user.displayName
            let token = user.refreshToken
            
            self.userCredentialPack.value = UserCredentialsPack(
                name: name ?? "",
                email: email ?? "",
                uid: uid,
                token: token ?? "")
            
            let newUser = User(
                name: name ?? "unKnown",
                email: email ?? "",
                photoURL: photoURL ?? "",
                uid: uid)
            
            checkIfUserExist(by: newUser)
            
        } else {
            
            self.userCredentialPack.value = UserCredentialsPack(
                name: "",
                email: "",
                uid: "",
                token: nil)
        }
    }
    
    // Check user
    func checkIfUserExist( by user: User) {
            
            if user.uid == "none" || user.uid == "" {
                return
            }
            
            firestoreManager.checkUser(by: user) { result in
                
                switch result {
                case .success(let users): print("fetched users: \(users)")
                    
                    self.userManager.currentUser = users.first ?? User()
                    self.userInfo.value = users.first ?? User()
                    
                case .failure(let error): print("\(error), user doesn't exist")
                    
                }
            }
        }
}

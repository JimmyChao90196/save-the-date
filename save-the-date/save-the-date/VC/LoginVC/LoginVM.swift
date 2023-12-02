//
//  LoginVM.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/12/2.
//

import Foundation
import UIKit
import GoogleSignIn

import FirebaseCore
import FirebaseAuthInterop
import FirebaseAuth

class LoginViewModel {
    
    var userInfo = Box(User())
    var userCredentialPack = Box(
        UserCredentialsPack(
            name: "",
            email: "",
            uid: "",
            token: ""))
    
    // Configure google sign in
    func configureGoogleSignIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
    }
    
    // Sign in to firebase with google
    func signInToFirebaseWithGoogle(idToken: String, accessToken: String) {
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        Auth.auth().signIn(with: credential) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            if let error = error {
                // Handle error
                return
            }
            // Handle successful sign-in (navigate to next screen or update UI)
            
            let user = Auth.auth().currentUser
            if let user = user {
                // The user's ID, unique to the Firebase project.
                // Do NOT use this value to authenticate with your backend server,
                // if you have one. Use getTokenWithCompletion:completion: instead.
                let uid = user.uid
                let email = user.email
                let photoURL = user.photoURL?.absoluteString
                let name = user.displayName
                let token = user.refreshToken
                
                self?.userCredentialPack.value = UserCredentialsPack(
                    name: name ?? "",
                    email: email ?? "",
                    uid: uid,
                    token: token ?? "")
                
                self?.userInfo.value = User(
                    name: name ?? "",
                    email: email ?? "",
                    photoURL: photoURL ?? "",
                    uid: uid)
            }
        }
    }
}

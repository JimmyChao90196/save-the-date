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

import AuthenticationServices
import CryptoKit

class LoginViewModel {
    
    typealias ASAuthDelegate = ASAuthorizationControllerDelegate
    typealias ASAuthPresentContext = ASAuthorizationControllerPresentationContextProviding
    
    // manager
    var firestoreManager = FirestoreManager.shared
    var userManager = UserManager.shared
    
    var currentNonce = Box<String?>(nil)
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
    
    func configureAppleSignIn(
        delegationTarget target: ASAuthDelegate &
        ASAuthPresentContext) {
            
            let nonce = randomNonceString()
            currentNonce.value = nonce
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = sha256(nonce)
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = target
            authorizationController.presentationContextProvider = target
            authorizationController.performRequests()
        }
    
    // Sign in to firebase with google
    func firebaseSignInWithGoogle(idToken: String, accessToken: String) {
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        Auth.auth().signIn(with: credential) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            if let error = error {
                // Handle error
                return
            }
            
            let user = Auth.auth().currentUser
            if let user = user {
                
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
                
                let newUser = User(
                    name: name ?? "",
                    email: email ?? "",
                    photoURL: photoURL ?? "",
                    uid: uid)
                
                self?.checkIfUserExist(by: newUser)
            }
        }
    }
    
    // Check user
    func checkIfUserExist(by user: User) {
        
        if user.email == "jimmy@gmail.com" || user.email == "none" || user.email == "" {
            return
        }
        
        firestoreManager.checkUser(by: user) { result in
            
            switch result {
            case .success(let users): print("fetched users: \(users)")
                self.userManager.currentUser = users.first ?? User()
                self.userManager.currentUser.photoURL = user.photoURL
                self.userInfo.value = users.first ?? User()
                
            case .failure(let error): print("\(error), create new user instead")
                
                let newUser = User(
                    name: user.name,
                    email: user.email,
                    photoURL: user.photoURL,
                    uid: user.uid)
                
                self.userInfo.value = newUser
                self.userManager.currentUser = newUser
                self.firestoreManager.addUserWithJson(newUser) { }
            }
        }
    }
}

// MARK: - Additional function -
extension LoginViewModel {
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        return hashString
    }
}

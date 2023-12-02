//
//  LoginVC.swift
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

import SnapKit

class LoginViewController: UIViewController {
    
    // Data
    var currentUserInfo = User()
    var userRefreshToken: String?
    
    // VM
    let viewModel = LoginViewModel()
    
    // Google signin button
    lazy var googleSignInButton: GIDSignInButton = {
        let button = GIDSignInButton()
        button.addTarget(self, action: #selector(googleSignInButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // On event
    var onLoggedIn: ((User) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        
        dataBinding()
        viewModel.configureGoogleSignIn()
        
        addTo()
        setupConstraint()
        
    }
    
    // Data binding
    func dataBinding() {
        
        viewModel.userRefreshToken.bind { token in
            self.userRefreshToken = token
            
            NotificationCenter.default.post(
                name: .userRefreshTokenUpdated,
                object: nil, userInfo: ["token": token])
        }
        
        viewModel.userInfo.bind { userInfo in
            self.currentUserInfo = userInfo
            
            print(self.currentUserInfo)
            self.dismiss(animated: true, completion: nil)
            self.onLoggedIn?(self.currentUserInfo)
        }
    }
    
    func addTo() {
        view.addSubviews([googleSignInButton])
    }
    
    func setupConstraint() {
        googleSignInButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(40)
            make.width.equalTo(150)
            make.height.equalTo(50)
        }
    }
    
    // MARK: - Additional function -
    
    @objc func googleSignInButtonTapped() {
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            guard error == nil else { return }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else { return }
            
            viewModel.signInToFirebaseWithGoogle(
                idToken: idToken,
                accessToken: user.accessToken.tokenString)
        }
    }
}

// MARK: - Notification -
extension Notification.Name {
    static let userRefreshTokenUpdated = Notification.Name("userRefreshTokenUpdated")
}


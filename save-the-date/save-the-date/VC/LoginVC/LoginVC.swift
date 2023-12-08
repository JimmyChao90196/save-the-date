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
    
    // Manager
    var userManager = UserManager.shared
    
    // Entering kind
    var enteringKind = EnterKind.create
    
    // Data
    var currentUserInfo = User()
    var userCredentialPack = UserCredentialsPack(
        name: "",
        email: "",
        uid: "",
        token: "")
    
    // VM
    let viewModel = LoginViewModel()
    var count = 0
    
    // Google signin button
    lazy var googleSignInButton: GIDSignInButton = {
        let button = GIDSignInButton()
        button.addTarget(self, action: #selector(googleSignInButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // Fake images that is about to be replaced with signin with apple
    var appleSignInImage = UIImageView(image: UIImage(resource: .signInWithAppleFakeIcon))
    
    // Guide label
    var guideLabel = UILabel()
    
    // icons
    var upperIcon = UIImageView(image: UIImage(resource: .travelIcon01))
    var lowerIcon = UIImageView(image: UIImage(resource: .travelIcon02))
    
    // Divider
    var dividerUpperLeft = UIView()
    var dividerUpperRight = UIView()
    var dividerLowerLeft = UIView()
    var dividerLowerRight = UIView()
    
    // On event
    var onLoggedIn: ((User) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .hexToUIColor(hex: "#FF4E4E")
        
        dataBinding()
        viewModel.configureGoogleSignIn()
        addTo()
        setupConstraint()
        setup()
        
    }
    
    // Data binding
    func dataBinding() {
        
        viewModel.userCredentialPack.bind { UCPack in
            self.userCredentialPack = UCPack
            
            NotificationCenter.default.post(
                name: .userCredentialsUpdated,
                object: UCPack)
        }
        
        // Fetch user from google
        viewModel.userInfo.bind { userInfo in
            
            self.currentUserInfo = userInfo
            
            self.onLoggedIn?(self.currentUserInfo)
            
            if self.count >= 1 {
                
                self.dismiss(animated: true) {
                    
                    switch self.enteringKind {
                        
                    case .deepLink(let docPath):
                        
                        let targetTabIndex = 1
                        
                        // Access the root TabBarController from the current UIWindowScene
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }),
                           let tabBarController = keyWindow.rootViewController as? UITabBarController {
                            
                            // Ensure the target tab index is valid
                            guard targetTabIndex < tabBarController.viewControllers?.count ?? 0 else {
                                print("Invalid tab index")
                                return
                            }
                            
                            // Switch to the target tab
                            tabBarController.selectedIndex = targetTabIndex
                            
                            if let navController = tabBarController.viewControllers?[targetTabIndex] as?
                                UINavigationController {
                                // Clear any existing view controllers on the stack if necessary
                                navController.popToRootViewController(animated: false)
                                
                                // Create and configure MultiUserViewController
                                let multiUserVC = MultiUserViewController()
                                multiUserVC.enterKind = .deepLink(docPath)
                                multiUserVC.documentPath = docPath
                                
                                // Push the MultiUserViewController onto the navigation stack
                                navController.pushViewController(multiUserVC, animated: true)
                            }
                        }
                        self.userManager.currentUser = userInfo
                    default: print("harray!!!")
                        self.userManager.currentUser = userInfo
                    }
                }
            }
            
            self.count += 1
        }
    }
    
    func setup() {
        guideLabel.text = "Please sign in"
        guideLabel.setFont(UIFont(name: "ChalkboardSE-Regular", size: 20)!)
        guideLabel.textColor = .hexToUIColor(hex: "#3F3A3A")
        
        googleSignInButton.style = .wide
        googleSignInButton.setCornerRadius(20)
            .clipsToBounds = true
        appleSignInImage.setCornerRadius(20)
            .clipsToBounds = true
        
        // Setup divider
        dividerUpperLeft.backgroundColor = .lightGray
        dividerUpperRight.backgroundColor = .lightGray
        dividerLowerLeft.backgroundColor = .lightGray
        dividerLowerRight.backgroundColor = .lightGray
    }
    
    func addTo() {
        view.addSubviews([
            googleSignInButton,
            guideLabel,
            upperIcon,
            lowerIcon,
            dividerUpperLeft,
            dividerUpperRight,
            dividerLowerLeft,
            dividerLowerRight,
            appleSignInImage
        ])
    }
    
    func setupConstraint() {
        
        guideLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(25)
            make.centerX.equalToSuperview()
        }
        
        upperIcon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(guideLabel.snp.bottom).offset(20)
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
        
        dividerUpperLeft.snp.makeConstraints { make in
            make.centerY.equalTo(upperIcon.snp.centerY)
            make.left.equalToSuperview().offset(80)
            make.right.equalTo(upperIcon.snp.left).offset(-10)
            make.height.equalTo(1)
        }
        
        dividerUpperRight.snp.makeConstraints { make in
            make.centerY.equalTo(upperIcon.snp.centerY)
            make.right.equalToSuperview().offset(-80)
            make.left.equalTo(upperIcon.snp.right).offset(10)
            make.height.equalTo(1)
        }
        
        googleSignInButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(upperIcon.snp.bottom).offset(20)
            make.width.equalTo(223)
            make.height.equalTo(15)
        }
        
        appleSignInImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(googleSignInButton.snp.bottom).offset(10)
            make.width.equalTo(215)
            make.height.equalTo(40)
        }
        
        lowerIcon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(appleSignInImage.snp.bottom).offset(20)
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
        
        dividerLowerLeft.snp.makeConstraints { make in
            make.centerY.equalTo(lowerIcon.snp.centerY)
            make.left.equalToSuperview().offset(80)
            make.right.equalTo(lowerIcon.snp.left).offset(-10)
            make.height.equalTo(1)
        }
        
        dividerLowerRight.snp.makeConstraints { make in
            make.centerY.equalTo(lowerIcon.snp.centerY)
            make.right.equalToSuperview().offset(-80)
            make.left.equalTo(lowerIcon.snp.right).offset(10)
            make.height.equalTo(1)
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
    static let userCredentialsUpdated = Notification.Name("userCredentialsUpdated")
}

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

import AuthenticationServices
import CryptoKit

import SnapKit
import Lottie

class LoginViewController: UIViewController {
    
    fileprivate var currentNonce: String?
    
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
    var googleSignInButton: GIDSignInButton = {
        let button = GIDSignInButton()
        button.frame = CGRect(x: 0, y: 0, width: 220, height: 50)
        return button
    }()
    
    var appleSignInButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton(
            authorizationButtonType: .signIn,
            authorizationButtonStyle: .black
        )
        button.frame = CGRect(x: 0, y: 0, width: 220, height: 45)
        return button
    }()
    
    // Guide label
    var guideLabel = UILabel()
    
    // icons
    var upperIcon = UIImageView(image: UIImage(resource: .travelIcon01))
    var lowerIcon = UIImageView(image: UIImage(resource: .travelIcon02))
    
    // Animation view
    var loginBGAnimation = LottieAnimationView()
    
    // Divider
    var dividerUpperLeft = UIView()
    var dividerUpperRight = UIView()
    var dividerLowerLeft = UIView()
    var dividerLowerRight = UIView()
    
    // On event
    var onLoggedIn: ((User) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        lottieAnimationSetup()
        
        dataBinding()
        viewModel.configureGoogleSignIn()
        addTo()
        setupConstraint()
        setup()
    }
    
    func lottieAnimationSetup() {
        
        // login animation setup
        loginBGAnimation = LottieAnimationView(name: "LoginBG")
        loginBGAnimation.contentMode = .scaleAspectFit
        loginBGAnimation.isUserInteractionEnabled = false
        loginBGAnimation.play()
        loginBGAnimation.animationSpeed = 0.5
        loginBGAnimation.loopMode = .autoReverse
        let blurEffect = UIBlurEffect(style: .systemThinMaterialLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
                                
        // Set the frame or use Auto Layout to constrain the blurEffectView
        blurEffectView.frame = loginBGAnimation.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Add the blur view to the view hierarchy
        loginBGAnimation.addSubview(blurEffectView)
    }
    
    // Data binding
    func dataBinding() {
        
        // Binding for nounce
        viewModel.currentNonce.bind { nonce in
            self.currentNonce = nonce
        }
        
        // Binding for credential
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
    
    // MARK: - Setup -
    func setup() {
        
        view.setBoarderColor(.black)
            .setBoarderWidth(3)
            .setCornerRadius(25)
            .clipsToBounds = true
        
        // Guide Label
        guideLabel.text = "Please sign in"
        guideLabel.setFont(UIFont(name: "ChalkboardSE-Regular", size: 20)!)
        guideLabel.textColor = .hexToUIColor(hex: "#3F3A3A")
        
        appleSignInButton.setCornerRadius(2.0)
        
        googleSignInButton.style = .wide
        googleSignInButton.clipsToBounds = true
        appleSignInButton.clipsToBounds = true
        
        // Setup divider
        dividerUpperLeft.backgroundColor = .lightGray
        dividerUpperRight.backgroundColor = .lightGray
        dividerLowerLeft.backgroundColor = .lightGray
        dividerLowerRight.backgroundColor = .lightGray
        
        // Sign in button setup
        googleSignInButton.addTarget(self, action: #selector(googleSignInButtonTapped), for: .touchUpInside)
        appleSignInButton.addTarget(self, action: #selector(appleSignInButtonTapped), for: .touchUpInside)
    }
    
    func addTo() {
        view.addSubviews([
            loginBGAnimation,
            googleSignInButton,
            appleSignInButton,
            guideLabel,
            upperIcon,
            lowerIcon,
            dividerUpperLeft,
            dividerUpperRight,
            dividerLowerLeft,
            dividerLowerRight,
        ])
        
    }
    
    func setupConstraint() {
        
        loginBGAnimation.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview().offset(20)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
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
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
        
        appleSignInButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(googleSignInButton.snp.bottom).offset(10)
            make.width.equalTo(195)
            make.height.equalTo(45)
        }
        
        lowerIcon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(appleSignInButton.snp.bottom).offset(20)
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
    
    // MARK: - Google login function -
    @objc func googleSignInButtonTapped() {
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            guard error == nil else { return }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else { return }
            
            viewModel.firebaseSignIn(
                with: .google,
                idToken: idToken,
                accessToken: user.accessToken.tokenString)
        }
    }
    
    // Sign in with apple
    @objc func appleSignInButtonTapped() {
        viewModel.configureAppleSignIn(delegationTarget: self)
    }
}

// MARK: - Notification -
extension Notification.Name {
    static let userCredentialsUpdated = Notification.Name("userCredentialsUpdated")
}

// MARK: - Apple login Delegate function -
extension LoginViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization) {
            
        // If login success
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            
            guard let appleIDToken = appleIDCredential.identityToken else {
                presentSimpleAlert(
                    title: "Warning",
                    message: "Unable to fetch identity token",
                    buttonText: "Okay")
                
                return
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                presentSimpleAlert(
                    title: "Warning",
                    message: "Unable to serialize token string from data\n\(appleIDToken.debugDescription)",
                    buttonText: "Okay")
                return
            }
            
            // Create credential for sign in
            let credential = OAuthProvider.credential(
                withProviderID: "apple.com",
                idToken: idTokenString,
                rawNonce: nonce)
            
            // Connect with firebase
            viewModel.firebaseSignIn(with: .apple(credential), idToken: "", accessToken: "")
        }
    }
    
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error) {
            
        // If login failed
        switch error {
        case ASAuthorizationError.canceled:
            presentSimpleAlert(
                title: "Error",
                message: "User cancel sign in",
                buttonText: "Okay")
            
        case ASAuthorizationError.failed:
            presentSimpleAlert(
                title: "Error",
                message: "Request for authorization failed",
                buttonText: "Okay")
            
        case ASAuthorizationError.invalidResponse:
            presentSimpleAlert(
                title: "Error",
                message: "Request and no response",
                buttonText: "Okay")
            
        case ASAuthorizationError.notHandled:
            presentSimpleAlert(
                title: "Error",
                message: "Request not handled",
                buttonText: "Okay")
            
        case ASAuthorizationError.unknown:
            presentSimpleAlert(
                title: "Error",
                message: "Auth faild for unknow reason",
                buttonText: "Okay")
            
        default:
            break
        }
    }
}

// MARK: - Present authorization controller
extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}

//
//  ProfileVC.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/18.
//

import Foundation
import UIKit
import SnapKit

import FirebaseStorage
import FirebaseCore
import FirebaseFirestoreSwift
import ImageIO

enum WaitingList {
    case profile
    case cover
    case profileImages
}

class ProfileViewController: ExplorePackageViewController {
    
    var selectionView = SelectionView()
    
    // About to be replaced
    var currentUser = User()
    var draftIDs = [String]()
    var pubIDs = [String]()
    var priIDs = [String]()
    
    // UI elements
    var profileCoverImage = UIImage(resource: .placeholder01)
    var profileCoverImageView = UIImageView(image: UIImage(resource: .placeholder01))
    var profilePicture = UIImageView(image: UIImage(systemName: "person.circle"))
    
    var descriptionView = UIView()
    var descriptionContent = UILabel()
    
    var userNameLabel = UILabel()
    var leftDivider = UIView()
    var rightDivider = UIView()
    var selectionDivider = UIView()
    
    // Packages
    var stateOfPackages = PackageState.favoriteState
    var currentPackages = [Package]()
    
    // Package profile images
    var currentProfileImages = [UIImage]()
    
    // Type
    var imageType = ImageType.profileImage
    
    // On event
    var onLoggedIn: ((User) -> Void)?
    
    // VM
    var waitingList: [WaitingList: Bool] = [
        .cover: false,
        .profile: false,
        .profileImages: false
    ]
    
    var countCurrentUserDataBinding = 0
    let profileVM = ProfileViewModel()
    
    // button
    lazy var editBGImageButton = {
        let button = UIBarButtonItem(
            image: UIImage(systemName: "square.and.pencil"),
            style: .plain,
            target: self,
            action: #selector(editBGTapped))
        
        return button
    }()
    
    lazy var loginButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis"),
            style: .plain,
            target: self,
            action: #selector(loginButtonPressed))
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = loginButton
        navigationItem.searchController = nil
        navigationItem.leftBarButtonItem = editBGImageButton
        
        setupProfileConstraint()
        dataBinding()
        setupOnEvent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        profileVM.fetchCurrentUser(userManager.currentUser.uid)
    }
    
    override func setup() {
        super.setup()
        view.addSubviews([
            profileCoverImageView,
            profilePicture,
            leftDivider,
            rightDivider,
            userNameLabel,
            descriptionView,
            descriptionContent,
            selectionView,
            selectionDivider
        ])
        
        self.selectionView.dataSource = self
        self.selectionView.delegate = self
        
        self.selectionView.setBoarderColor(.black)
            .setCornerRadius(15)
            .setBoarderWidth(2)
            .setbackgroundColor(.hexToUIColor(hex: "#87D6DD"))
        
        profilePicture.setCornerRadius(35)
            .setBoarderColor(.black)
            .setBoarderWidth(2.0)
            .contentMode = .scaleAspectFill
        
        profilePicture.tintColor = .hexToUIColor(hex: "#3F3A3A")
        profilePicture.backgroundColor = .white
        profilePicture.clipsToBounds = true
        
        profileCoverImageView.contentMode = .scaleAspectFill
        profileCoverImageView.tintColor = .customUltraGrey
        profileCoverImageView.clipsToBounds = true
        
        // Dividers
        leftDivider.backgroundColor = .darkGray
        rightDivider.backgroundColor = .darkGray
        selectionDivider.backgroundColor = .darkGray
        
        userNameLabel.setFont(UIFont(name: "ChalkboardSE-Regular", size: 24)!)
            .setTextColor(.hexToUIColor(hex: "#3F3A3A"))
            .text = "Unknow"
        
        animateBGView.stop()
        
        // Fetch profileCover
        profileVM.fetchProfileCoverImage(with: self.userManager.currentUser.coverURL)
        LKProgressHUD.show()
        
        // Hide folded view
        foldedView.isHidden = true
        
        // Set background view
        tableView.backgroundColor = .hexToUIColor(hex: "#E5E5E5")
        view.backgroundColor = .hexToUIColor(hex: "#E5E5E5")
        
        // Description view
        descriptionView.setCornerRadius(10)
            .setBoarderColor(.black)
            .setBoarderWidth(2.5)
        descriptionContent.numberOfLines = 0
        descriptionContent.textAlignment = .center
        descriptionContent.setFont(UIFont(name: "ChalkboardSE-Regular", size: 14)!)
            .setTextColor(.hexToUIColor(hex: "#3F3A3A"))
            .text = "Be kind, for everyone is fighting a hard battle."
    }
    
    // Discard old constraint
    override func setupConstraint() { }
    
    // MARK: - Additional function -
    
    func presentPicker() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        
        // Present the image picker
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc func editBGTapped() {
        
        presentSimpleAlert(
            by: ["Profile photo", "Cover photo", "User name"],
            title: "Change photo",
            message: "Which info you wanna change") { alertAction in
                switch alertAction.title {
                    
                case "Profile photo": self.imageType = .profileImage
                    self.presentPicker()
                    
                case "Cover photo": self.imageType = .profileCover
                    self.presentPicker()
                    
                default:
                    self.presentAlertWithTextField(
                        title: "New name",
                        message: "Please enter your new name",
                        buttonText: "Okay") { text in
                            guard let newName = text else { return }
                            
                            self.userNameLabel.text = newName
                            self.currentUser.name = newName
                            self.userManager.currentUser.name = newName
                            self.profileVM.updateUserName(newName)
                        }
                }
            }
    }
    
    func setupOnEvent() {
        onLoggedIn = { [weak self] user in
            self?.profileVM.checkIfUserExist(by: user)
        }
    }
    
    func dataBinding() {
        
        // Fetch coverImage
        profileVM.profileCoverImage.bind { image in
            
            if image != UIImage() {
                DispatchQueue.main.async {
                    self.profileCoverImageView.image = image
                    self.waitingList[.cover] = true
                    
                    self.profileVM.shouldDismiss(list: self.waitingList)
                }
            }
        }
        
        // Fetch profileImage
        profileVM.profileImage.bind { profileImage in
            
            if profileImage != UIImage() {
                self.userManager.userProfileImage = profileImage
                
                DispatchQueue.main.async {
                    self.profilePicture.image = self.userManager.userProfileImage ??
                    UIImage(systemName: "person.circle")
                    
                    self.waitingList[.profile] = true
                    
                    self.profileVM.shouldDismiss(list: self.waitingList)
                }
            }
        }
        
        // Fetch packages
        profileVM.currentUser.bind { fetchedUser in
            
            if fetchedUser.uid != "" {
                
                self.currentUser = fetchedUser
                
                // This is stupid
                self.userManager.currentUser = fetchedUser
                
                // fetch profile image
                self.profileVM.fetchUserProfileImage()
                self.profileVM.fetchProfileCoverImage(
                    with: self.userManager.currentUser.coverURL)
                LKProgressHUD.show()
                
                DispatchQueue.main.async {
                    self.userNameLabel.text = fetchedUser.name
                    self.fetchOperation()
                    self.tableView.reloadData()
                    self.profilePicture.image = self.userManager.userProfileImage ??
                    UIImage(systemName: "person.circle")
                }
            }
        }
        
        // Fetch profileImages
        profileVM.currentProfileImages.bind { currentProfileImages in
            self.currentProfileImages = currentProfileImages
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.waitingList[.profileImages] = true
                self.profileVM.shouldDismiss(list: self.waitingList)
            }
        }
        
        // Fetch packages
        profileVM.currentPackages.bind {
            self.currentPackages = $0
        }
    }
    
    @objc func loginButtonPressed() {
        let loginVC = LoginViewController()
        
        presentSimpleAlert(
            by: ["Switch account", "Delete account"],
            title: "Account setting",
            message: "Please choose the following operation",
            buttonText: "Okay") { alertAction in
                
                switch alertAction.title {
                case "Switch account":
                    
                    loginVC.onLoggedIn = self.onLoggedIn
                    loginVC.modalPresentationStyle = .automatic
                    loginVC.modalTransitionStyle = .coverVertical
                    loginVC.enteringKind = .create
                    loginVC.sheetPresentationController?.detents = [.custom(resolver: { context in
                        context.maximumDetentValue * 0.35
                    })]
                    self.present(loginVC, animated: true)
                    
                default:
                    self.presentSimpleAlert(
                        title: "Warning",
                        message: "You are about to delete your account",
                        buttonText: "Okay") {
                            self.profileVM.deleteAccount { result in
                                switch result {
                                case .success(let credPack):
                                    
                                    NotificationCenter.default.post(
                                        name: .userCredentialsUpdated,
                                        object: credPack)
                                    
                                    let nvc = self.navigationController
                                    nvc?.popToRootViewController(animated: false)
                                    nvc?.tabBarController?.selectedIndex = 0
                                    
                                    DispatchQueue.main.async {
                                        self.profileCoverImageView.image = UIImage(resource: .placeholder04)
                                    }
                                    
                                case .failure(let failure):
                                    LKProgressHUD.showFailure(text: "Sensitive operation, login again if failed.")
                                }
                            }
                        }
                }
            }
    }
}

// MARK: - Fetch operations -
extension ProfileViewController {
    
    func fetchOperation() {
        profileVM.fetchPackages(with: stateOfPackages)
    }
}

// MARK: - Selection View DataSource method -
extension ProfileViewController: SelectionViewDataSource, SelectionViewProtocol {
    func buttonPerSelection(selectionView: SelectionView, index: Int) -> SelectionButton {
        return selectionsData[index]
    }
    
    func colorOfBar(selectionView: SelectionView ) -> UIColor? {
        return .black
    }
    
    func numberOfButtons(selectionView: SelectionView) -> Int {
        selectionsData.count
    }
    
    // MARK: - Selection view delegate method -
    func didSelectButtonAt(
        selectionView: SelectionView,
        displayColor: UIColor,
        selectionIndex: Int) {
            switch selectionIndex {
            case 0: stateOfPackages = .favoriteState
            case 1: stateOfPackages = .publishedState
            case 2: stateOfPackages = .draftState
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    LKProgressHUD.showFailure(text: "Not available yet")
                }
            default: stateOfPackages = .favoriteState
            }
            
            waitingList[.profileImages] = false
            self.fetchOperation()
            LKProgressHUD.show()
        }
}

// MARK: - Table view dataSource method -
extension ProfileViewController {
    
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath) {
            let packageDetailVC = PackageDetailViewController()
            packageDetailVC.enterFrom = .profile
            packageDetailVC.currentPackage = currentPackages[indexPath.row]
            navigationController?.pushViewController(packageDetailVC, animated: true)
        }
    
    override func numberOfSections(
        in tableView: UITableView) -> Int {
            1
        }
    
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
            self.currentPackages.count
        }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ExploreTableViewCell.reuseIdentifier,
                for: indexPath) as? ExploreTableViewCell else { return UITableViewCell() }
            
            let authorNameArray = currentPackages[indexPath.row].info.author
            let authorName = authorNameArray.joined(separator: " ")
            
            let tags = viewModel.createTagsView(
                for: indexPath,
                packages: currentPackages)
            
            cell.configureStackView(with: tags)
            cell.packageAuthor.text = " by \(authorName) "
            cell.packageTitleLabel.text = currentPackages[indexPath.row].info.title
            cell.heartImageView.isHidden = true
            cell.onLike = nil
            
            if currentProfileImages.isEmpty == false {
                cell.authorPicture.image = currentProfileImages[indexPath.row]
            }
            cell.authorPicture.tintColor = .customUltraGrey
            return cell
        }    
}

// MARK: - Image picker delegate -
extension ProfileViewController: 
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate {
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            
            picker.dismiss(animated: true, completion: nil)
            
            if let selectedImage = info[.originalImage] as? UIImage {
                var targetSize = profileVM.calculateAspectRatioSize(
                    for: selectedImage,
                    maxWidth: 100,
                    maxHeight: 100)
                
                switch self.imageType {
                    
                case .profileImage:
                    print("do nothing")
                case .profileCover:
                    targetSize = profileVM.calculateAspectRatioSize(
                        for: selectedImage,
                        maxWidth: 256,
                        maxHeight: 256)
                }
                profileVM.downsample(
                    image: selectedImage,
                    to: targetSize) { image in
                        guard let image else { return }
                        
                        self.profileVM.uploadImages(
                            type: self.imageType,
                            targetImage: image)
                        
                        DispatchQueue.main.async {
                            
                            switch self.imageType {
                                
                            case .profileImage: self.profilePicture.image = image
                            case .profileCover: self.profileCoverImageView.image = image
                            }
                        }
                    }
            }
        }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

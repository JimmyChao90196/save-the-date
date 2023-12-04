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

class ProfileViewController: ExplorePackageViewController {
    
    var selectionView = SelectionView()
    
    // About to be replaced
    var count = 0
    var currentUser = User()
    
    var draftIDs = [String]()
    var pubIDs = [String]()
    var priIDs = [String]()
    
    // UI elements
    var profileBGImage = UIImageView(image: UIImage(resource: .profileBG))
    var profilePicture = UIImageView(image: UIImage(systemName: "person.crop.circle.fill"))
    
    var descriptionView = UIView()
    var descriptionContent = UILabel()
    var descriptionHBlock = UIView()
    var descriptionVBlock = UIView()
    
    var userNameLabel = UILabel()
    var leftDivider = UIView()
    var rightDivider = UIView()
    
    // Packages
    var stateOfPackages = PackageState.favoriteState
    var favPackages = [Package]()
    var pubPackages = [Package]()
    var draftPackages = [Package]()
    var currentPackages: [Package] {
        
        switch stateOfPackages {
        case .favoriteState: return favPackages
        case .publishedState: return pubPackages
        case .draftState: return draftPackages
        default: return favPackages
            
        }
    }
    
    // Profile images
    var favProfileImages = [UIImage]()
    var pubProfileImages = [UIImage]()
    var draftProfileImages = [UIImage]()
    var currentProfileImages: [UIImage] {
        
        switch stateOfPackages {
        case .favoriteState: return favProfileImages
        case .publishedState: return pubProfileImages
        case .draftState: return draftProfileImages
        default: return favProfileImages
            
        }
    }
    
    // On event
    var onLoggedIn: ((User) -> Void)?
    
    // VM
    let profileVM = ProfileViewModel()
    
    // Nav button
    lazy var testButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(systemName: "square.and.pencil"),
            style: .plain,
            target: self,
            action: #selector(testButtonPressed))
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = testButton
        navigationItem.searchController = nil
        navigationItem.leftBarButtonItem = nil
        
        dataBinding()
        setupOnEvent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        profileVM.fetchCurrentUser(userManager.currentUser.email)
        // fetchOperation()
    }
    
    override func setup() {
        super.setup()
        view.addSubviews([
            profileBGImage,
            profilePicture,
            leftDivider,
            rightDivider,
            userNameLabel,
            descriptionView,
            descriptionHBlock,
            descriptionVBlock,
            descriptionContent,
            selectionView
        ])
        
        self.selectionView.dataSource = self
        self.selectionView.delegate = self
        self.selectionView.setBoarderColor(.black)
            .setCornerRadius(15)
            .setBoarderWidth(3)
            .setbackgroundColor(.hexToUIColor(hex: "#87D6DD"))
        
        profilePicture.setCornerRadius(35).contentMode = .scaleAspectFill
        profilePicture.tintColor = .hexToUIColor(hex: "#3F3A3A")
        profilePicture.backgroundColor = .white
        profilePicture.clipsToBounds = true
        
        profileBGImage.contentMode = .scaleToFill
        
        // Dividers
        leftDivider.backgroundColor = .darkGray
        rightDivider.backgroundColor = .darkGray
        
        userNameLabel.setFont(UIFont(name: "ChalkboardSE-Regular", size: 24)!)
            .setTextColor(.hexToUIColor(hex: "#3F3A3A"))
            .text = "Jimmy"
        
        // Hide folded view
        foldedView.isHidden = true
        
        // Set background view
        view.backgroundColor = .hexToUIColor(hex: "#CCCCCC")
        tableView.backgroundColor = .hexToUIColor(hex: "#CCCCCC")
        
        // Description view
        descriptionView.setCornerRadius(10)
            .setBoarderColor(.black)
            .setBoarderWidth(2.5)
        descriptionHBlock.backgroundColor = .blue
        descriptionVBlock.backgroundColor = .hexToUIColor(hex: "#CCCCCC")
        descriptionContent.numberOfLines = 0
        descriptionContent.textAlignment = .center
        descriptionContent.setFont(UIFont(name: "ChalkboardSE-Regular", size: 14)!)
            .setTextColor(.hexToUIColor(hex: "#3F3A3A"))
            .text = "Be kind, for everyone you meet is fighting a hard battle."
    }
    
    override func setupConstraint() {
        
        // Description
        descriptionView.snp.makeConstraints { make in
            make.top.equalTo(profileBGImage.snp.bottom).offset(10)
            make.bottom.equalTo(selectionView.snp.top).offset(-10)
            make.leading.equalTo(userNameLabel.snp.trailing).offset(40)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        descriptionContent.snp.makeConstraints { make in
            make.centerY.equalTo(descriptionView.snp.centerY)
            make.leading.equalTo(descriptionView.snp.leading).offset(15)
            make.trailing.equalTo(descriptionView.snp.trailing).offset(-15)
        }
        
        descriptionHBlock.snp.makeConstraints { make in
            make.leading.equalTo(descriptionView.snp.leading).offset(-5)
            make.trailing.equalTo(descriptionView.snp.trailing).offset(5)
            make.centerY.equalTo(descriptionView.snp.centerY)
            make.height.equalTo(25)
        }
        
        descriptionVBlock.snp.makeConstraints { make in
            make.top.equalTo(descriptionView.snp.top).offset(-5)
            make.bottom.equalTo(descriptionView.snp.bottom).offset(5)
            make.centerX.equalTo(descriptionView.snp.centerX)
            make.width.equalTo(100)
        }
        
        userNameLabel.snp.makeConstraints { make in
            make.top.equalTo(profilePicture.snp.bottom).offset(10)
            make.centerX.equalTo(profilePicture.snp.centerX)
        }
        
        profileBGImage.snp.makeConstraints { make in
            make.top.equalTo(view.snp_topMargin)
            make.height.equalTo(190)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        profilePicture.snp.makeConstraints { make in
            make.centerY.equalTo(profileBGImage.snp.bottom)
            make.leading.equalToSuperview().offset(25)
            make.height.equalTo(70)
            make.width.equalTo(70)
        }
        
        leftDivider.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalTo(profilePicture.snp.leading).offset(-10)
            make.top.equalTo(profileBGImage.snp.bottom).offset(-15)
            make.height.equalTo(2.5)
        }
        
        rightDivider.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.leading.equalTo(profilePicture.snp.trailing).offset(10)
            make.top.equalTo(profileBGImage.snp.bottom).offset(-15)
            make.height.equalTo(2.5)
        }
        
        selectionView.snp.makeConstraints { make in
            make.top.equalTo(profilePicture.snp.bottom).offset(50)
            make.height.equalTo(50)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(selectionView.snp.bottom)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.bottom.equalTo(view.snp_bottomMargin)
        }
    }
    
 // MARK: - Additional function -
    func setupOnEvent() {
        onLoggedIn = { [weak self] user in
            self?.profileVM.checkIfUserExist(by: user)
        }
    }
    
    func dataBinding() {
        
        // Fetch profileImage
        profileVM.profileImage.bind { profileImage in
            self.userManager.userProfileImage = profileImage
            
            DispatchQueue.main.async {
                self.profilePicture.image = self.userManager.userProfileImage
            }
        }
        
        // Fetch packages
        profileVM.currentUser.bind { fetchedUser in
            
            self.currentUser = fetchedUser
            
            // This is stupid
            if self.count != 0 {
                self.userManager.currentUser = fetchedUser
            }
            self.count += 1
            
            // fetch profile image
            self.profileVM.fetchUserProfileImage()
            
            DispatchQueue.main.async {
                self.userNameLabel.text = fetchedUser.name
                self.fetchOperation()
                self.tableView.reloadData()
                self.profilePicture.image = self.userManager.userProfileImage
            }
        }
        
        // Fetch profileImages
        profileVM.favProfileImages.bind { favProfileImages in
            self.favProfileImages = favProfileImages
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        profileVM.pubProfileImages.bind { pubProfileImages in
            self.pubProfileImages = pubProfileImages
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        profileVM.draftProfileImages.bind { draftProfileImages in
            self.draftProfileImages = draftProfileImages
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        // Fetch packages
        profileVM.favPackages.bind { favPackages in
            self.favPackages = favPackages
            
        }
        
        profileVM.pubPackages.bind { pubPackages in
            self.pubPackages = pubPackages

        }
        
        profileVM.draftPackages.bind { draftPackages in
            self.draftPackages = draftPackages

        }
    }
    
    @objc func testButtonPressed() {
        let loginVC = LoginViewController()
        
        loginVC.onLoggedIn = self.onLoggedIn
        
        if let sheetPresentationController = loginVC.presentationController as? UISheetPresentationController {
            sheetPresentationController.detents = [.medium()]
            present(loginVC, animated: true)
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
            default: stateOfPackages = .favoriteState
            }
            
            self.fetchOperation()
        }
}

// MARK: - Table view dataSource method -
extension ProfileViewController {
    
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
            
            cell.packageTitleLabel.text = currentPackages[indexPath.row].info.title
            cell.heartImageView.isHidden = true
            cell.onLike = nil
            cell.authorPicture.image = currentProfileImages[indexPath.row]
            
            return cell
        }
}

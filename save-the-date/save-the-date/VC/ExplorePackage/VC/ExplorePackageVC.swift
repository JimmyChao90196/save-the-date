//
//  ExplorePackageVC.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/18.
//

import Foundation
import UIKit

import SnapKit
import CoreLocation

import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseCore
import Lottie

import QuartzCore

class ExplorePackageViewController: ExploreBaseViewController, ResultViewControllerDelegate {
    
    // url
    var url: URL?
    
    // VM
    var count = 0
    let viewModel = ExploreViewModel()
    var userCredentialsPack = UserCredentialsPack(
        name: "",
        email: "",
        uid: "",
        token: nil)
    
    // Stack view
    let dynamicStackView = UIStackView()
    
    // ScrollView
    var recommandedScrollView = HorizontalImageScrollView()
    
    // Search bar
    var searchController = UISearchController()
    
    // Manager
    var userManager = UserManager.shared
    
    // UI
    var tagGuide = UILabel()
    lazy var applyButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        
        // Your logic to customize the button
        button.backgroundColor = .blue
        button.setTitle("Apply", for: .normal)
        
        // Adding an action
        button.addTarget(self, action: #selector(applyButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    // Animation view
    var animateBGView = LottieAnimationView()
    
    // inside folded view
    var cityPicker = UIPickerView()
    var districtPicker = UIPickerView()
    var chooseCityLabel = UILabel()
    var chooseDistrictLabel = UILabel()
    
    // Divider
    var labelLeftDividerA = UILabel()
    var labelRightDividerA = UILabel()
    
    var labelLeftDividerB = UILabel()
    var labelRightDividerB = UILabel()
    
    var bannerTopDivider = UIView()
    var bannerBottomDivider = UIView()
    var bannerTopDividerB = UIView()
    
    // Folded view
    var foldedView = UIView()
    var foldedViewLeadingConstraint: NSLayoutConstraint!
    var isFolded = true
    
    var currentCity = TaiwanCityModel.taipei
    var currentDistrict = ""
    var inputTags = ["Taipei City", "Da’an District"]
    
    var hotsPaths = [String]()
    
    var fetchedPackages = [Package]()
    var fetchedProfileImages = [UIImage]()
    var fetchedProfileImagesDic = [String: UIImage]()
    
    var packageAuthorLabel = UILabel()
    var onLike: ((UITableViewCell, Bool) -> Void)?
    var onTapped: ((Int) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handelOnEvent()
        
        // Add observer
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCredentialsUpdate(notification:)),
            name: .userCredentialsUpdated,
            object: nil)
        
        // Setup scrollView
        self.recommandedScrollView.onTapped = self.onTapped
        self.recommandedScrollView.backgroundColor = .hexToUIColor(hex: "#CCCCCC")
        view.backgroundColor = .hexToUIColor(hex: "#E5E5E5")
        
        // add filter navgation button
        let filterButton = UIBarButtonItem(
            image: UIImage(systemName: "slider.horizontal.3"),
            style: .plain,
            target: self,
            action: #selector(filterButtonTapped))
        navigationItem.leftBarButtonItem = filterButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if type(of: self) == ExplorePackageViewController.self {
            fetchPackages()
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func addTo() {
        super.addTo()
        view.addSubviews([
            animateBGView,
            recommandedScrollView,
            bannerTopDivider,
            bannerBottomDivider,
            bannerTopDividerB,
            dynamicStackView,
            tagGuide,
            foldedView
        ])
        
        view.sendSubviewToBack(animateBGView)
        
        foldedView.addSubviews([
            chooseCityLabel,
            chooseDistrictLabel,
            cityPicker,
            districtPicker,
            applyButton,
            labelLeftDividerA,
            labelRightDividerA,
            labelLeftDividerB,
            labelRightDividerB
        ])
    }
    
    override func setup() {
        super.setup()
        
        animateBGView = LottieAnimationView(name: "ChatBG")
        animateBGView.isUserInteractionEnabled = false
        animateBGView.contentMode = .scaleAspectFit
        animateBGView.play()
        animateBGView.loopMode = .loop
        
        // Notification Center listener
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCredentialsUpdate(notification:)),
            name: .userCredentialsUpdated,
            object: nil)
        
        // Dynamic stack view
        dynamicStackView.axis = .horizontal
        dynamicStackView.spacing = 10
        dynamicStackView.alignment = .center
        dynamicStackView.distribution = .fillEqually
        dynamicStackView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        // Customize search
        if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            textfield.backgroundColor = UIColor.hexToUIColor(hex: "#DDDDDD").withAlphaComponent(0.75)
            textfield.textColor = UIColor.black
            
            // Color of the placeholder text
            let placeholderAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.gray]
            let attributedPlaceholder = NSAttributedString(string: "Search...", attributes: placeholderAttributes)
            textfield.attributedPlaceholder = attributedPlaceholder
            
            // Cursor color
            textfield.tintColor = UIColor.red
        }
        
        // Setup picker
        cityPicker.dataSource = self
        cityPicker.delegate = self
        
        districtPicker.dataSource = self
        districtPicker.delegate = self
        
        // Binding
        viewModel.fetchedPackages.bind { [weak self] packages in
            
            self?.fetchedPackages = packages
            self?.viewModel.fetchUserProfileImages(from: packages)
            
            // Reload tableView
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
            
            if type(of: self) == ExplorePackageViewController.self {
                
                LKProgressHUD.dismiss()
            }
        }
        
        // Fetched profile images
        viewModel.fetchedProfileImagesDic.bind { imagesDic in
            
            if imagesDic != [:] {
                
                self.fetchedProfileImagesDic = imagesDic
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
                if type(of: self) == ExplorePackageViewController.self {
                    
                    LKProgressHUD.dismiss()
                }
            }
        }
        
        // Binding for path
        viewModel.hotsPaths.bind { paths in
            self.hotsPaths = paths
        }
        
        // Setup folded view
        setupFoldedView()
        
        // Setup search bar
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        fetchPackages()
        recommandedScrollView.addImages(
            named: ["crown",
                    "crown-silver",
                    "3rd",
                    "3rd",
                    "3rd",
                    "3rd"
                   ])
        
        // Add gesture recognition
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        chooseCityLabel.text = "City"
        chooseDistrictLabel.text = "District"
        
        // Setup label
        chooseCityLabel.setCornerRadius(10)
            .setBoarderWidth(2)
            .setBoarderColor(.hexToUIColor(hex: "#3F3A3A"))
            .setbackgroundColor(.hexToUIColor(hex: "#87D6DD"))
            .setTextColor(.white)
            .setFont(UIFont(name: "ChalkboardSE-Regular", size: 20)!)
            .clipsToBounds = true
        
        chooseDistrictLabel.setCornerRadius(10)
            .setBoarderWidth(2)
            .setBoarderColor(.hexToUIColor(hex: "#3F3A3A"))
            .setbackgroundColor(.hexToUIColor(hex: "#87D6DD"))
            .setTextColor(.white)
            .setFont(UIFont(name: "ChalkboardSE-Regular", size: 20)!)
            .clipsToBounds = true
        
        chooseDistrictLabel.textAlignment = .center
        chooseCityLabel.textAlignment = .center
        
        // Setup picker
        cityPicker.setCornerRadius(10)
            .setBoarderWidth(2)
            .setBoarderColor(.hexToUIColor(hex: "#3F3A3A"))
        
        districtPicker.setCornerRadius(10)
            .setBoarderWidth(2)
            .setBoarderColor(.hexToUIColor(hex: "#3F3A3A"))
        
        applyButton.setCornerRadius(5)
            .setBoarderColor(.hexToUIColor(hex: "#3F3A3A"))
            .setBoarderWidth(2)
            .setbackgroundColor(.hexToUIColor(hex: "#8691FF"))
            .clipsToBounds = true
        
        // Setup divider
        labelLeftDividerA.backgroundColor = .hexToUIColor(hex: "#3F3A3A")
        labelLeftDividerB.backgroundColor = .hexToUIColor(hex: "#3F3A3A")
        labelRightDividerA.backgroundColor = .hexToUIColor(hex: "#3F3A3A")
        labelRightDividerB.backgroundColor = .hexToUIColor(hex: "#3F3A3A")
        bannerTopDivider.backgroundColor = .black
        bannerBottomDivider.backgroundColor = .black
        bannerTopDividerB.backgroundColor = .black
        
        // Tag guide
        tagGuide.text = "-> Swipe right to see filter options"
        tagGuide.setFont(UIFont(name: "ChalkboardSE-Regular", size: 20)!)
            .setTextColor(.lightGray)
        
        // Setup tableView
        view.backgroundColor = .clear
        tableView.backgroundColor = .clear
        tableView.backgroundView = UIImageView(image: UIImage(resource: .createBG03))
        tableView.backgroundView?.contentMode = .scaleAspectFill
        
        // Handle deep link if exist
        if url != nil {
            handleDeepLink(url: url!)
        }
    }
    
    override func setupConstraint() {
        
        animateBGView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.topMargin)
            make.bottom.equalTo(view.snp.bottomMargin)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        // Setup stack view
        dynamicStackView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.topMargin)
            make.leading.equalToSuperview().offset(50)
            make.trailing.equalToSuperview().offset(-50)
            make.height.equalTo(50)
        }
        
        // Tag guide
        tagGuide.snp.makeConstraints { make in
            make.centerY.equalTo(dynamicStackView.snp.centerY)
            make.leading.equalToSuperview().offset(20)
        }
        
        // Set up scroll view
        recommandedScrollView.snp.makeConstraints { make in
            make.top.equalTo(dynamicStackView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(100)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(recommandedScrollView.snp.bottom)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.bottom.equalTo(view.snp_bottomMargin)
        }
        
        foldedView.snp.makeConstraints { make in
            make.top.equalTo(view.snp_topMargin)
            make.width.equalTo(200)
            make.bottom.equalTo(view.snp.bottomMargin)
        }
        
        // Set the initial position off-screen
        foldedViewLeadingConstraint = foldedView.leadingAnchor.constraint(
            equalTo: view.leadingAnchor,
            constant: -200)
        foldedViewLeadingConstraint.isActive = true
        
        chooseCityLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
        }
        
        cityPicker.snp.makeConstraints { make in
            make.top.equalTo(chooseCityLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(150)
        }
        
        chooseDistrictLabel.snp.makeConstraints { make in
            make.top.equalTo(cityPicker.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
        }
        
        districtPicker.snp.makeConstraints { make in
            make.top.equalTo(chooseDistrictLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(150)
        }
        
        applyButton.snp.makeConstraints { make in
            make.top.equalTo(districtPicker.snp.bottom).offset(25)
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(30)
        }
        
        labelLeftDividerA.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalTo(chooseCityLabel.snp.leading).offset(-10)
            make.height.equalTo(2)
            make.centerY.equalTo(chooseCityLabel.snp.centerY)
        }
        
        labelRightDividerA.snp.makeConstraints { make in
            make.leading.equalTo(chooseCityLabel.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(2)
            make.centerY.equalTo(chooseCityLabel.snp.centerY)
        }
        
        labelLeftDividerB.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalTo(chooseDistrictLabel.snp.leading).offset(-10)
            make.height.equalTo(2)
            make.centerY.equalTo(chooseDistrictLabel.snp.centerY)
        }
        
        labelRightDividerB.snp.makeConstraints { make in
            make.leading.equalTo(chooseDistrictLabel.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(2)
            make.centerY.equalTo(chooseDistrictLabel.snp.centerY)
        }
        
        bannerTopDivider.snp.makeConstraints { make in
            make.top.equalTo(view.snp.topMargin)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(3)
        }
        
        bannerTopDividerB.snp.makeConstraints { make in
            make.top.equalTo(dynamicStackView.snp.bottomMargin)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(3)
        }
        
        bannerBottomDivider.snp.makeConstraints { make in
            make.top.equalTo(recommandedScrollView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(3)
        }
    }
}

// MARK: - Additional method -
extension ExplorePackageViewController {
    
    @objc func handleCredentialsUpdate(notification: Notification) {
        if let credentials = notification.object as? UserCredentialsPack {
            // Handle the credentials update
            print("Received new credentials: \(credentials)")
            
            self.userCredentialsPack = credentials
            self.userManager.userCredentialsPack = credentials
        }
    }
    
    @objc private func handleDeepLinkNotification(_ notification: Notification) {
        if let url = notification.object as? URL {
            DispatchQueue.main.async {
                self.tagGuide.text = "\(url)"
            }
        }
    }
    
    func fetchPackages() {
        viewModel.fetchPackages(from: .publishedColl)
        LKProgressHUD.show()
    }
    
    func setupFoldedView() {
        
        isFolded = true
        
        foldedView.setbackgroundColor(.hexToUIColor(hex: "#FF4E4E"))
            .layer.shadowColor = UIColor.hexToUIColor(hex: "#3F3A3A").cgColor
        foldedView.layer.shadowRadius = 10
        foldedView.setBoarderColor(.hexToUIColor(hex: "#3F3A3A"))
            .setCornerRadius(20)
            .setBoarderWidth(2.5)
            .layer.shadowOpacity = 0.6
    }
    
    func animateConstraint(newConstant: CGFloat) {
        // Calculate the new constant for the leading constraint
        let newConstant: CGFloat = newConstant
        
        // Animate the constraint change
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.3) {
                self.foldedViewLeadingConstraint.constant = newConstant
                self.view.layoutIfNeeded()
            }
    }
    
    @objc func filterButtonTapped() {
        isFolded.toggle()
        
        if isFolded {
            animateConstraint(newConstant: -200)
        } else {
            animateConstraint(newConstant: 0)
        }
    }
    
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        
        if gesture.direction == .right {
            animateConstraint(newConstant: 0)
            
        } else if gesture.direction == .left {
            animateConstraint(newConstant: -200)
        }
    }
}

// MARK: - Data Source method -
extension ExplorePackageViewController {
    
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
            fetchedPackages.count
        }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ExploreTableViewCell.reuseIdentifier,
                for: indexPath) as? ExploreTableViewCell else { return UITableViewCell() }
            
            let likedByArray = fetchedPackages[indexPath.row].info.likedBy
            let isInFavorite = likedByArray.contains { uid in
                uid == userManager.currentUser.uid
            }
            
            // Handle isLike logic
            cell.isLike = isInFavorite
            
            switch isInFavorite {
            case true: cell.heartImageView.image = UIImage(
                systemName: "heart.fill")
                
            case false: cell.heartImageView.image = UIImage(
                systemName: "heart")
            }
            
            let authorNameArray = fetchedPackages[indexPath.row].info.author
            let authorName = authorNameArray.joined(separator: " ")
            let authorPhotoURL = fetchedPackages[indexPath.row].photoURL
            
            let tags = viewModel.createTagsView(
                for: indexPath,
                packages: fetchedPackages)
            
            cell.configureStackView(with: tags)
            cell.packageAuthor.text = " by \(authorName) "
            cell.packageTitleLabel.text = fetchedPackages[indexPath.row].info.title
            
            cell.authorPicture.image = fetchedProfileImagesDic[authorPhotoURL]
            
            cell.authorPicture.tintColor = .customUltraGrey
            cell.onLike = self.onLike
            
            return cell
        }
    
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath) {
            
            let packageDetailVC = PackageDetailViewController()
            packageDetailVC.enterFrom = .explore
            packageDetailVC.currentPackage = fetchedPackages[indexPath.row]
            navigationController?.pushViewController(packageDetailVC, animated: true)
        }
}

// MARK: - Additional method -
extension ExplorePackageViewController {
    
    @objc func applyButtonTapped() {
        
        viewModel.fetchedSearchedPackages(by: self.inputTags)
    }
    
    func handelOnEvent() {
        
        // Handle on event
        self.onTapped = { index in
            let packageDetailVC = PackageDetailViewController()
            packageDetailVC.currentPackage = self.fetchedPackages[index]
            self.navigationController?.pushViewController(packageDetailVC, animated: true)
        }
        
        // On like button tapped
        onLike = { cell, isLike in
            
            // let token = self.userCredentialsPack.token
            let token = self.userManager.userCredentialsPack.token
            
            if token == nil || token == "" {
                
                let loginVC = LoginViewController()
                loginVC.modalPresentationStyle = .automatic
                loginVC.modalTransitionStyle = .coverVertical
                loginVC.enteringKind = .create
                loginVC.sheetPresentationController?.detents = [.custom(resolver: { context in
                    context.maximumDetentValue * 0.35
                })]
                
                self.navigationController?.present(loginVC, animated: true)
                
                return
            }
            
            guard let indexPathToEdit = self.tableView.indexPath(for: cell)
            else { return }
            
            let docPath = self.fetchedPackages[indexPathToEdit.row].docPath
            
            switch isLike {
            case true:
                
                self.viewModel.afterLiked(
                    userId: self.userManager.currentUser.uid,
                    docPath: docPath,
                    perform: .add) {
                        self.presentSimpleAlert(
                            title: "Success",
                            message: "Successfully added to favorite",
                            buttonText: "Ok")
                    }
                
            case false:
                
                self.viewModel.afterLiked(
                    userId: self.userManager.currentUser.uid,
                    docPath: docPath,
                    perform: .remove) {
                        self.presentSimpleAlert(
                            title: "Success",
                            message: "Successfully delete from favorite",
                            buttonText: "Ok")
                    }
                
            }
        }
    }
}

// MARK: - Search Delegate method -

extension ExplorePackageViewController: UISearchResultsUpdating, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // Did tap protocol
    func didTapPlace(
        with coordinate: CLLocationCoordinate2D,
        targetPlace: Location) {
        }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let text = searchController.searchBar.text else { return }
        self.viewModel.fetchedSearchedPackages(by: text)
    }
    
    // MARK: - UIPickerViewDelegate methods -
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(
        _ pickerView: UIPickerView,
        numberOfRowsInComponent component: Int) -> Int {
            
            if pickerView == self.cityPicker {
                return TaiwanCityModel.allCases.count
            } else {
                return currentCity.districts.count
            }
        }
    
    func pickerView(
        _ pickerView: UIPickerView,
        titleForRow row: Int,
        forComponent component: Int) -> String? {
            
            if pickerView == self.cityPicker {
                return TaiwanCityModel.allCases[row].rawValue
            } else {
                return currentCity.districts[row]
            }
        }
    
    func pickerView(
        _ pickerView: UIPickerView,
        didSelectRow row: Int,
        inComponent component: Int) {
            
            if pickerView == self.cityPicker {
                currentCity = TaiwanCityModel.allCases[row]
                self.inputTags[0] = self.currentCity.rawValue
                self.districtPicker.reloadAllComponents()
                self.inputTags[1] = self.currentCity.districts[0]
                
            } else {
                currentDistrict = currentCity.districts[row]
                self.inputTags[1] = currentDistrict
            }
            
            print(self.inputTags)
            let tags = viewModel.createTagsView(inputTags: inputTags)
            DispatchQueue.main.async {
                self.configureStackView(with: tags)
            }
            
            self.tagGuide.isHidden = true
            
            viewModel.fetchedSearchedPackages(by: self.inputTags)
        }
}

// Configure stackView for city and district tags
extension ExplorePackageViewController {
    
    func configureStackView(with elements: [UIView]) {
        // Clear existing arrangedSubviews
        dynamicStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        
        // Add new elements
        for element in elements {
            dynamicStackView.addArrangedSubview(element)
        }
    }
}

extension ExplorePackageViewController {
    func handleDeepLink(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems,
              let sessionId = queryItems.first(where: { $0.name == "id" })?.value else {
            print("Invalid deep link URL")
            return
        }
        
        // Prompt to login first
        let loginVC = LoginViewController()
        loginVC.modalPresentationStyle = .automatic
        loginVC.modalTransitionStyle = .coverVertical
        loginVC.enteringKind = .deepLink(sessionId)
        loginVC.sheetPresentationController?.detents = [.custom(resolver: { context in
            context.maximumDetentValue * 0.35
        })]
        navigationController?.present(loginVC, animated: true)
    }
}

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

import QuartzCore

class ExplorePackageViewController: ExploreBaseViewController, ResultViewControllerDelegate {
    
    // VM
    let viewModel = ExploreViewModel()
    
    // ScrollView
    var recommandedScrollView = HorizontalImageScrollView()
    
    // Search bar
    var searchController = UISearchController()
    
    // UI
    lazy var applyButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        
        // Your logic to customize the button
        button.backgroundColor = .blue
        button.setTitle("Apply", for: .normal)
        
        // Adding an action
        button.addTarget(self, action: #selector(applyButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    var cityPicker = UIPickerView()
    var districtPicker = UIPickerView()
    var foldedView = UIView()
    var foldedViewLeadingConstraint: NSLayoutConstraint!
    
    var isFolded = true
    var currentCity = TaiwanCityModel.taipei
    var currentDistrict = ""
    var inputTags = ["Taipei City", "Da’an District"]
    
    var hotsPaths = [String]()
    var fetchedPackages = [Package]()
    var packageAuthorLabel = UILabel()
    var onLike: ((UITableViewCell, Bool) -> Void)?
    var onTapped: ((Int) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handelOnEvent()
        
        // Setup scrollView
        self.recommandedScrollView.onTapped = self.onTapped
        
        view.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchPackages()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func addTo() {
        super.addTo()
        view.addSubviews([
            recommandedScrollView,
            foldedView
        ])
        
        foldedView.addSubviews([
            cityPicker,
            districtPicker,
            applyButton
        ])
    }
    
    override func setup() {
        super.setup()
        
        // Setup picker
        cityPicker.dataSource = self
        cityPicker.delegate = self
        
        districtPicker.dataSource = self
        districtPicker.delegate = self
        
        // Binding
        viewModel.fetchedPackages.bind { [weak self] packages in
            self?.fetchedPackages = packages
            DispatchQueue.main.async {
                self?.tableView.reloadData()
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
        recommandedScrollView.backgroundColor = .white
        recommandedScrollView.addImages(
            named: ["Placeholder01",
                    "Placeholder02",
                    "Placeholder03",
                    "Placeholder04",
                    "Placeholder05",
                    "Placeholder06",
                    "Placeholder07",
                    "Placeholder08"
                    ])
        
        // Add gesture recognition
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    override func setupConstraint() {
        
        recommandedScrollView.snp.makeConstraints { make in
            make.top.equalTo(view.snp_topMargin)
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
            make.bottom.equalTo(view.snp_bottomMargin)
        }
        
        // Set the initial position off-screen
        foldedViewLeadingConstraint = foldedView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -200)
        foldedViewLeadingConstraint.isActive = true
        
        cityPicker.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(150)
             
        }
        
        districtPicker.snp.makeConstraints { make in
            make.top.equalTo(cityPicker.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(150)
        }
        
        applyButton.snp.makeConstraints { make in
            make.top.equalTo(districtPicker.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(50)
        }
    }
}

// MARK: - Additional method -
extension ExplorePackageViewController {
    
    func fetchPackages() {
        viewModel.fetchPackages(from: .publishedColl)
    }
    
    func setupFoldedView() {
        
        isFolded = true
        
        foldedView.setbackgroundColor(.red)
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
            let isInFavorite = likedByArray.contains { email in
                email == "jimmy@gmail.com"
            }
            
            // Handle isLike logic
            cell.isLike = isInFavorite
            
            switch isInFavorite {
            case true: cell.heartImageView.image = UIImage(
                systemName: "heart.fill")
                
            case false: cell.heartImageView.image = UIImage(
                systemName: "heart")
            }
            
            let authorName = fetchedPackages[indexPath.row].info.author
            cell.packageAuthor.text = "by \(authorName)"
            cell.packageTitleLabel.text = fetchedPackages[indexPath.row].info.title
            cell.onLike = self.onLike
            
            return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let packageDetailVC = PackageDetailViewController()
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
            
            guard let indexPathToEdit = self.tableView.indexPath(for: cell)
            else { return }
            
            let docPath = self.fetchedPackages[indexPathToEdit.row].docPath
            
            switch isLike {
            case true:

                self.viewModel.afterLiked(
                    email: "jimmy@gmail.com",
                    docPath: docPath,
                    perform: .add) {
                        self.presentSimpleAlert(
                            title: "Success",
                            message: "Successfully added to favorite",
                            buttonText: "Ok")
                    }
                
            case false:
                
                self.viewModel.afterLiked(
                    email: "jimmy@gmail.com",
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
        }
}

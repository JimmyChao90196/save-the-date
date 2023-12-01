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
    
    // folded view
    var cityPicker = UIPickerView()
    var districtPicker = UIPickerView()
    
    var foldedView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 300))
    
    var isFolded = true
    
    var fetchedPackages = [Package]()
    var packageAuthorLabel = UILabel()
    var onLike: ((UITableViewCell, Bool) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handelOnEvent()
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
            foldedView,
            cityPicker,
            districtPicker
        ])
    }
    
    override func setup() {
        super.setup()
        
        // Setup picker
        cityPicker.dataSource = self
        cityPicker.delegate = self
        
        districtPicker.dataSource = self
        districtPicker.delegate = self
        
        // Setup nav button
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "line.horizontal.3.decrease.circle"),
            style: .plain,
            target: self,
            action: #selector(triggerFolding)
        )
        
        // Binding
        viewModel.fetchedPackages.bind { [weak self] packages in
            self?.fetchedPackages = packages
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
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
    }
}

// MARK: - Additional method -
extension ExplorePackageViewController {
    
    func fetchPackages() {
        viewModel.fetchPackages(from: .publishedColl)
    }
    
    func setupFoldedView() {
        
        isFolded = false
        
        foldedView.setbackgroundColor(.red)
            .layer.shadowColor = UIColor.hexToUIColor(hex: "#3F3A3A").cgColor
        foldedView.layer.shadowRadius = 20
        foldedView.setBoarderColor(.hexToUIColor(hex: "#3F3A3A"))
            .setCornerRadius(20)
            .setBoarderWidth(2.5)
            .layer.shadowOpacity = 0.95
        
        // Set initial anchor
        foldedView.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        foldedView.frame = CGRect(x: 0, y: 160, width: 200, height: 550)

        var transform = CATransform3DIdentity
        transform.m34 = -1.0 / 1000
        transform = CATransform3DRotate(transform, -CGFloat.pi / 2, 0, 1, 0)
        foldedView.layer.transform = transform
    }
    
    @objc func triggerFolding() {
        
        view.layoutIfNeeded()

        // Setup anchor
        foldedView.layer.anchorPoint = CGPoint(x: 0, y: 0.5)

        let newAngle: CGFloat = isFolded ? -CGFloat.pi / 2 : 0

        // Start the property animator
        let animator = UIViewPropertyAnimator(duration: 0.25, curve: .easeOut) {
            var transform = CATransform3DIdentity
            transform.m34 = -1.0 / 1000
            transform = CATransform3DRotate(transform, newAngle, 0, 1, 0)
            self.foldedView.layer.transform = transform
        }

        animator.addCompletion { position in
            if position == .end {
                self.isFolded.toggle()
            }
        }
        animator.startAnimation()
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
            
            // Handle is like logic
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
    
    func handelOnEvent() {
        
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

// MARK: - Delegate method -

extension ExplorePackageViewController: UISearchResultsUpdating, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // Did tap protocol
    func didTapPlace(
        with coordinate: CLLocationCoordinate2D,
        targetPlace: Location) {
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        self.viewModel.fetchedSearchedPackages(
            targetController: searchController)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // Number of components (or "wheels")
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count // Number of rows in the component
    }

    // UIPickerViewDelegate methods
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        print("Selected item: \(pickerData[row])")
    }

}

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

class ExplorePackageViewController: ExploreBaseViewController {
    
    // ScrollView
    var recommandedScrollView = HorizontalImageScrollView()
    
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
        view.addSubviews([recommandedScrollView])
    }
    
    override func setup() {
        super.setup()
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
        
        firestoreManager.fetchJsonPackages(from: .publishedColl) { [weak self] result in
            switch result {
            case .success(let packages):
                self?.fetchedPackages = packages
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("unable to fetch packages: \(error)")
            }
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
                // Update user package stack
                self.firestoreManager.updateUserPackages(
                    email: "jimmy@gmail.com",
                    packageType: .favoriteColl,
                    packageID: docPath,
                    perform: .add
                ) {
                        self.presentSimpleAlert(
                            title: "Success",
                            message: "Successfully added to favorite",
                            buttonText: "Ok")
                    }
                // Update package email stack
                self.firestoreManager.updatePackage(
                    infoToUpdate: "jimmy@gmail.com",
                    // packageType: .publishedColl,
                    packageID: docPath,
                    toPath: .likedBy,
                    perform: .add
                ) {
                        print("successfully updated")
                        self.fetchPackages()
                    }
                
            case false:
                
                // Update user package stack
                self.firestoreManager.updateUserPackages(
                    email: "jimmy@gmail.com",
                    packageType: .favoriteColl,
                    packageID: docPath,
                    perform: .remove
                ) {
                        self.presentSimpleAlert(
                            title: "Success",
                            message: "Successfully delete",
                            buttonText: "Ok")
                    }
                // Update package email stack
                self.firestoreManager.updatePackage(
                    infoToUpdate: "jimmy@gmail.com",
                    // packageType: .publishedColl,
                    packageID: docPath,
                    toPath: .likedBy,
                    perform: .remove
                ) {
                        print("successfully removed")
                        self.fetchPackages()
                    }
                
            }
        }
    }
}

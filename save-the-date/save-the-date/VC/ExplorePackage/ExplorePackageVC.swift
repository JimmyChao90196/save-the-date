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
    
    var fetchedPackages = [Package]()
    var onLike: ((UITableViewCell, Bool) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handelOnEvent()
 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchPackages()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func setup() {
        super.setup()
        fetchPackages()
        
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
            
            let packageID = self.fetchedPackages[indexPathToEdit.row].info.id
            
            switch isLike {
            case true:
                // Update user package stack
                self.firestoreManager.updateUserPackages(
                    email: "jimmy@gmail.com",
                    packageType: .favoriteColl,
                    packageID: packageID,
                    perform: .add
                ) {
                        self.presentSimpleAlert(
                            title: "Success",
                            message: "Successfully added to favorite",
                            buttonText: "Ok")
                    }
                
                self.firestoreManager.updatePackage(
                    emailToUpdate: "jimmy@gmail.com",
                    packageType: .publishedColl,
                    packageID: packageID,
                    toPath: .likedBy) {
                        print("successfully updated")
                        self.fetchPackages()
                    }
                
            case false:
                
                // Update user package stack
                self.firestoreManager.updateUserPackages(
                    email: "jimmy@gmail.com",
                    packageType: .favoriteColl,
                    packageID: packageID,
                    perform: .remove
                ) {
                        self.presentSimpleAlert(
                            title: "Success",
                            message: "Successfully delete",
                            buttonText: "Ok")
                    }
                
            }
        }
    }
}

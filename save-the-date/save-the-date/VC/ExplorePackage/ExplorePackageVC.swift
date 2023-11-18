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

// MARK: - Additional method
extension ExplorePackageViewController {
    func fetchPackages() {
        firestoreManager.fetchPackages(from: .publishedColl) { [weak self] result in
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
            
            return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let packageDetailVC = PackageDetailViewController()
        packageDetailVC.currentPackage = fetchedPackages[indexPath.row]
        navigationController?.pushViewController(packageDetailVC, animated: true)
    }
}

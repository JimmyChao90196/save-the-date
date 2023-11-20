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
    
    var favIDs = [String]()
    var draftIDs = [String]()
    var pubIDs = [String]()
    var priIDs = [String]()
    
    var favPackages = [Package]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        fetchOperation()
    }
    
    override func setup() {
        super.setup()
        view.addSubviews([selectionView])
        self.selectionView.dataSource = self
        self.selectionView.backgroundColor = .blue
    }
    
    override func setupConstraint() {
        
        selectionView.snp.makeConstraints { make in
            make.top.equalTo(view.snp_topMargin)
            make.height.equalTo(50)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(selectionView.snp.bottom)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.bottom.equalTo(view.snp_bottomMargin)
        }
    }
}

// MARK: - Fetch operations -
extension ProfileViewController {
    
    func fetchOperation() {
        Task {
            do {
                let userEmail = "jimmy@gmail.com"
                let user = try await firestoreManager.fetchUser(userEmail)
                
                favIDs = user.favoritePackages
                
                favPackages = try await firestoreManager.fetchFavPackages(withIDs: favIDs)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            } catch {
                print("Error occurred: \(error)")
            }
        }
    }
}

// MARK: - Selection View DataSource method -
extension ProfileViewController: SelectionViewDataSource {
    func buttonPerSelection(selectionView: SelectionView, index: Int) -> SelectionButton {
        return selectionsData[index]
    }
    
    func colorOfBar(selectionView: SelectionView ) -> UIColor? {
        return .blue
    }
    
    func numberOfButtons(selectionView: SelectionView) -> Int {
        selectionsData.count
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
            favPackages.count
        }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ExploreTableViewCell.reuseIdentifier,
                for: indexPath) as? ExploreTableViewCell else { return UITableViewCell() }
            
            cell.packageTitleLabel.text = favPackages[indexPath.row].info.title
            cell.heartImageView.isHidden = true
            cell.onLike = nil
            
            return cell
        }
}

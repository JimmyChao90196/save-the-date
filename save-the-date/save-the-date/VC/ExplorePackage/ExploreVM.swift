//
//  ExploreViewModel.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/30.
//

import Foundation
import FirebaseCore
import FirebaseFirestoreSwift
import UIKit
import SnapKit

class ExploreViewModel {
    
    var userManager = UserManager.shared
    var firestoreManager = FirestoreManager.shared
    var fetchedPackages = Box<[Package]>([])
    var fetchedProfileImages = Box<[UIImage]>([])
    var fetchedProfileImagesDic = Box<[String: UIImage]>([:])
    var hotsPaths = Box<[String]>([])
    
    // fetch searched packages
    func fetchedSearchedPackages(by tags: [String]) {
        
        let copyTags = tags

        firestoreManager.searchPackages(by: copyTags) { result in
            
            switch result {
            case .success(let packages):
                
                var resultPackages = [Package]()
                packages.forEach {
                    
                    if $0.regionTags.contains(where: { $0 == tags[1] }) {
                        resultPackages.append($0)
                    }
                }

                self.fetchedPackages.value = resultPackages
                
            case .failure(let error): print(error)
            }
        }
    }
    
    func fetchedSearchedPackages(by text: String) {
        firestoreManager.searchPackages(by: text) { result in
            
            switch result {
            case .success(let packages):
                self.fetchedPackages.value = packages
                
            case .failure(let error): print(error)
            }
        }
    }
    
    // Fetch userProfile images
    func fetchUserProfileImages(from packages: [Package]) {
        let urls = packages.map { $0.photoURL }
        
        self.userManager.downloadImagesToDic(from: urls, completion: { result in
            switch result {
            case .success(let imagesDic):
                self.fetchedProfileImagesDic.value = imagesDic
                
            case .failure(let error):
                print(error)
            }
        })
    }
    
    // fetch initial packages
    func fetchPackages(from collection: PackageCollection) {
        firestoreManager.fetchJsonPackages(from: collection) { [weak self] result in
            switch result {
            case .success(let packages):
                self?.fetchedPackages.value = packages
                
                self?.hotsPaths.value = packages.map { $0.docPath }
                
            case .failure(let error):
                print("unable to fetch packages: \(error)")
            }
        }
    }
    
    // update user package
    func afterLiked(
        userId uid: String,
        docPath: String,
        perform: PackageOperation,
        completion: (() -> Void)?
    ) {
        
        // Update user package stack
        self.firestoreManager.updateUserPackages(
            userId: uid,
            packageType: .favoriteColl,
            docPath: docPath,
            perform: perform
        ) {
            completion?()
        }
        // Update package uid stack
        self.firestoreManager.updatePackage(
            infoToUpdate: uid,
            docPath: docPath,
            toPath: .likedBy,
            perform: perform
        ) {
            
            self.fetchPackages(from: .publishedColl)
        }
    }
    
    // MARK: - Create tags view -
    func createTagsView(for indexPath: IndexPath, packages: [Package]) -> [UIView] {
        // Example: create UIImageViews or UILabels based on your model
        
        let tags = packages[indexPath.row].regionTags.prefix(2)
        
        var labelArray = [UILabel]()
        let colors = [UIColor.hexToUIColor(hex: "#86CEFF"), UIColor.hexToUIColor(hex: "#8691FF")]
        
        // Tags label with random color
        for (index, tag) in tags.enumerated() {
            let label = UILabel()
            label.text = tag
            label.font = UIFont(name: "HelveticaNeue", size: 15)
            label.textColor = .black
            label.textAlignment = .center
            label.backgroundColor = colors[index]
            label.layer.cornerRadius = 5
            label.layer.masksToBounds = true
            
            labelArray.append(label)
        }
        return labelArray
    }
    
    func createTagsView(inputTags: [String]) -> [UIView] {
        // Example: create UIImageViews or UILabels based on your model
        
        var labelArray = [UILabel]()
        
        // Tags label with random color
        for tag in inputTags {
            let label = UILabel()
            label.text = tag
            label.font = UIFont(name: "ChalboardSE-Regular", size: 18)
            label.textColor = .black
            label.textAlignment = .center
            label.backgroundColor = .hexToUIColor(hex: "#CCCCCC")
            label.setCornerRadius(10)
                .setBoarderColor(.black)
                .setBoarderWidth(1)
                .clipsToBounds = true
            
            label.snp.makeConstraints { make in
                make.height.equalTo(30)
            }
            
            label.layer.cornerRadius = 5
            label.layer.masksToBounds = true
            labelArray.append(label)
        }
        return labelArray
    }
}

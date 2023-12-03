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

class ExploreViewModel {
    
    var userManager = UserManager.shared
    var firestoreManager = FirestoreManager.shared
    var fetchedPackages = Box<[Package]>([])
    var fetchedProfileImages = Box<[UIImage]>([])
    
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
        
        self.userManager.downloadImages(from: urls, completion: { result in
            switch result {
            case .success(let images):
                self.fetchedProfileImages.value = images
                
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
        email: String,
        docPath: String,
        perform: PackageOperation,
        completion: (() -> Void)?
    ) {
        
        // Update user package stack
        self.firestoreManager.updateUserPackages(
            email: email,
            packageType: .favoriteColl,
            docPath: docPath,
            perform: perform
        ) {
            completion?()
        }
        // Update package email stack
        self.firestoreManager.updatePackage(
            infoToUpdate: email,
            docPath: docPath,
            toPath: .likedBy,
            perform: perform
        ) {
            
            self.fetchPackages(from: .publishedColl)
        }
    }
}

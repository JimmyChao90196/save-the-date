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
    
    var firestoreManager = FirestoreManager.shared
    var fetchedPackages = Box<[Package]>([])
    
    // fetch searched packages
    func fetchedSearchedPackages(targetController controller: UISearchController) {
        guard let text = controller.searchBar.text else { return }
        
        firestoreManager.searchPackages(by: text) { result in
            
            switch result {
            case .success(let packages):
                self.fetchedPackages.value = packages
                
            case .failure(let error): print(error)
                
            }
        }
    }
    
    // fetch initial packages
    func fetchPackages(from collection: PackageCollection) {
        
        firestoreManager.fetchJsonPackages(from: collection) { [weak self] result in
            switch result {
            case .success(let packages):
                self?.fetchedPackages.value = packages
                
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

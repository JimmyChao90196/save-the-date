//
//  PackageDetailVM.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/12/9.
//

import Foundation
import UIKit

class PackageDetailViewModel {
    
    let userManager = UserManager.shared
    let firestoreManager = FirestoreManager.shared
    
    var authorImages = Box<[UIImage]>([])
    var isInEditMode = Box(false)
    var shouldEdit = Box(false)
    
    func enterPackageMode() {
        isInEditMode.value = true
    }
    
    func submitRequest(
        targetDocPath path: String,
        requestType: RequestType,
        completion: @escaping () -> Void
    ) {
        firestoreManager.submitRequest(
            targetDocPath: path,
            .report) { result in
                switch result {
                case .success(let requestID):
                    print("Successfully submit the request: \(requestID)")
                case .failure(let error):
                    print("submit failed: \(error)")
                }
            }
    }
    
    // Fetch author images
    func fetchAuthorImages(emails: [String]) {
        Task {
            
            do {
                let users = try await firestoreManager.searchUsers(by: emails)
                let photoURLs = users.map { $0.photoURL }
                
                userManager.downloadImages(from: photoURLs) { result in
                
                    switch result {
                    case .success(let images):
                        self.authorImages.value = images
                    case .failure(let error):
                        print("failed to fetch images \(error)")
                    }
                }
                
            } catch {
                print("Couldn't fetch the users\(error)")
            }
        }
    }
    
    // Save reiveced packages
    func saveRevicedPackage(package: Package) {
        isInEditMode.value = false
        
        let copyPackage = package
        // copyPackage.photoURL = self.userManager.currentUser.photoURL
        
        self.firestoreManager.overridePackage(copyPackage) { result in
            switch result {
                
            case .success(let documentID):
                print("Successfully update the package: \(documentID)")
                
            case .failure(let error):
                print("publish failed: \(error)")
            }
        }
    }
    
    func shouldEdit(
        autherEmails emails: [String],
        from viewContorller: EnterFrom) {
            
            var isProfile = false
            var shouldEdit = false
            let isUser = emails.contains { $0 == userManager.currentUser.email }
            switch viewContorller {
                
            case .explore: isProfile = false
                
            case .profile: isProfile = true
            }
            
            if isProfile == false || isUser == false {
                shouldEdit = false
            } else {
                shouldEdit = true
            }
            
            self.shouldEdit.value = shouldEdit
            
            // Output result
            // completion(shouldEdit)
        }
}

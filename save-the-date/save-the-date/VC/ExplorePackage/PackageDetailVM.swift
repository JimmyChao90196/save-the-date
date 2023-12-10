//
//  PackageDetailVM.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/12/9.
//

import Foundation

class PackageDetailViewModel {
    
    let userManager = UserManager.shared
    let firestoreManager = FirestoreManager.shared
    
    var isInEditMode = Box(false)
    
    func enterPackageMode() {
        isInEditMode.value = true
    }
    
    // Fetch author images
    func fetchAuthorImages() {
        
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
        from viewContorller: EnterFrom, completion: ((Bool) -> Void)) {
            
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
            
            // Output result
            completion(shouldEdit)
        }
}

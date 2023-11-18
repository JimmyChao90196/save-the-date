//
//  FirebaseManager.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/18.
//

import Foundation
import FirebaseFirestore
import UIKit

enum FirestoreError: Error {
    case userNotFound
    case userAlreadyExist
}

class FirestoreManager {
    
    static let shared = FirestoreManager()
    
    let fdb =  Firestore.firestore()
    
    var collectionId = "packages"
    
    // MARK: - Add user -
    func addUser(_ user: User, completion: @escaping () -> Void) {
        fdb.collection("users").document(user.email).setData(user.dictionary) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                completion()
            }
        }
    }
    
    // MARK: - Publish package
    func publishPackage(_ package: Package, completion: @escaping (Result<String, Error>) -> Void) {
        var ref: DocumentReference?
        ref = fdb.collection("packages").addDocument(data: package.dictionary) { error in
            if let error = error {
                completion(.failure(error))
            } else if let documentID = ref?.documentID {
                completion(.success(documentID))
            }
        }
    }
    
    // MARK: - Update user package -
    func updateUserPackages(
        email: String,
        packageType: String,
        packageID: String,
        completion: @escaping () -> Void) {
            
        let userRef = fdb.collection("users").document(email)
        userRef.updateData([packageType: FieldValue.arrayUnion([packageID])
        ]) { error in
            if let error = error {
                print("Error updating user: \(error)")
            } else {
                completion()
            }
        }
    }
}

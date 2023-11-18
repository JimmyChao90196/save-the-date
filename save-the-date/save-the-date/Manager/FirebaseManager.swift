//
//  FirebaseManager.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/18.
//

import Foundation
import FirebaseFirestore
import UIKit

enum PublishError: Error {
    case encodeError
    case failedAddToDocument
}

enum FirestoreError: Error {
    case userNotFound
    case userAlreadyExist
}

class FirestoreManager {
    static let shared = FirestoreManager()
    
    let fdb =  Firestore.firestore()
    
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
    
    // MARK: - Publish package -
    func publishPackage(_ package: Package, completion: @escaping (Result<String, Error>) -> Void) {
        var ref: DocumentReference?
        
        let packageColl = PackageCollection.publishedColl
        
        ref = fdb.collection(packageColl.rawValue).addDocument(data: package.dictionary) { error in
            if let error = error {
                completion(.failure(error))
            } else if let documentID = ref?.documentID {
                completion(.success(documentID))
            }
        }
    }
    
    // MARK: - Publish package 02 -
    func publishPackageWithJson(_ package: Package, completion: @escaping (Result<String, Error>) -> Void) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            // Encode your package object into JSON
            let jsonData = try encoder.encode(package)
            
            // Convert JSON data to a dictionary
            guard let dictionary = try JSONSerialization.jsonObject(
                with: jsonData,
                options: .allowFragments) as? [String: Any] else {
                print("Json serialization error")
                return
            }
            
            var ref: DocumentReference?
            let packageColl = PackageCollection.publishedColl
            
            // Upload the JSON dictionary to Firestore
            ref = fdb.collection(packageColl.rawValue).addDocument(data: dictionary) { error in
                if let error = error {
                    completion(.failure(error))
                } else if let documentID = ref?.documentID {
                    completion(.success(documentID))
                }
            }
        } catch {
            // Handle encoding errors
            completion(.failure(error))
        }
    }
    
    // MARK: - Update user -
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
    
    // MARK: - Fetch packaeges
    func fetchPackages(
        from packageCollection: PackageCollection,
        completion: @escaping (Result<[Package], Error>) -> Void) {
            
        fdb.collection(packageCollection.rawValue).getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            var packages: [Package] = []
            querySnapshot?.documents.forEach { document in
                let data = document.data()
                let package = Package(convertFrom: data)
                packages.append(package)
            }

            completion(.success(packages))
        }
    }
}

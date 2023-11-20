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
    
    // MARK: - Publish package with json -
    func publishPackageWithJson(_ package: Package, completion: @escaping (Result<String, Error>) -> Void) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            // Create a document reference first
            let packageColl = PackageCollection.publishedColl.rawValue
            let newDocumentRef = fdb.collection(packageColl).document()
            let newDocumentID = newDocumentRef.documentID
            
            var packageCopy = package
            packageCopy.info.id = newDocumentID
            
            // Encode your package object into JSON
            let jsonData = try encoder.encode(packageCopy)
            
            // Convert JSON data to a dictionary
            guard let dictionary = try JSONSerialization.jsonObject(
                with: jsonData,
                options: .allowFragments) as? [String: Any] else {
                print("Json serialization error")
                return
            }
            
            // Upload the JSON dictionary to Firestore
            newDocumentRef.setData(dictionary) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(newDocumentID))
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
        packageType: PackageCollection,
        packageID: String,
        completion: @escaping () -> Void) {
            
        let userRef = fdb.collection("users").document(email)
            userRef.updateData([packageType.rawValue: FieldValue.arrayUnion([packageID])
        ]) { error in
            if let error = error {
                print("Error updating user: \(error)")
            } else {
                completion()
            }
        }
    }
    
    // MARK: - Update package -
    func updatePackage(
        emailToUpdate userEmail: String,
        packageType: PackageCollection,
        packageID: String,
        toPath path: PackageFieldPath,
        completion: @escaping () -> Void
    ) {
        
        let packageRef = fdb.collection(packageType.rawValue).document(packageID)
        let fieldPath = "info.\(path.rawValue)"
        packageRef.updateData([fieldPath: FieldValue.arrayUnion([userEmail])
        ]) { error in
            if let error = error {
                print("Error updating package: \(error)")
            } else {
                completion()
            }
        }
    }
    
    // MARK: - Fetch json packages -
    func fetchJsonPackages(
        from packageCollection: PackageCollection,
        completion: @escaping (Result<[Package], Error>) -> Void) {
        
        fdb.collection(packageCollection.rawValue).getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            var packages: [Package] = []
            let decoder = JSONDecoder()
            
            querySnapshot?.documents.forEach { document in
                do {
                    // Convert the document data to JSON Data
                    let jsonData = try JSONSerialization.data(withJSONObject: document.data(), options: [])
                    // Decode the JSON Data to a Package02 object
                    let package = try decoder.decode(Package.self, from: jsonData)
                    packages.append(package)
                } catch {
                    completion(.failure(error))
                    return
                }
            }

            completion(.success(packages))
        }
    }
}

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
    
    // MARK: - Add user with json
    func addUserWithJson(_ user: User, completion: @escaping () -> Void) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            // Encode your user object into JSON
            let jsonData = try encoder.encode(user)

            // Convert JSON data to a dictionary
            let dictionary = try jsonData.toDictionary()
            
            // Upload the JSON dictionary to Firestore
            fdb.collection("users").document(user.uid).setData(dictionary) { error in
                if let error = error {
                    print("uploaded failed: \(error)")
                } else {
                    completion()
                }
            }
        } catch {
            // Handle encoding errors
            print("error")
        }
    }
    
    // MARK: - Publish package with json -
    func uploadPackage(
        _ package: Package,
        _ packageColl: PackageCollection = PackageCollection.publishedColl,
        completion: @escaping (Result<String, Error>) -> Void) {
            
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            // Create a document reference first
            let packageColl = packageColl.rawValue
            let newDocumentRef = fdb.collection(packageColl).document()
            let newDocumentID = newDocumentRef.documentID
            var packageCopy = package
            
            // Change this to ref
            // packageCopy.info.id = newDocumentID
            packageCopy.docPath = newDocumentRef.path
            
            // Encode your package object into JSON and converted it to a dictionary
            let jsonData = try encoder.encode(packageCopy)
            let dictionary = try jsonData.toDictionary()
            
            // Upload the JSON dictionary to Firestore
            newDocumentRef.setData(dictionary) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(newDocumentRef.path))
                }
            }
        } catch {
            // Handle encoding errors
            completion(.failure(error))
        }
    }
    
    // MARK: - Override packages -
    func overridePackage(
        _ targetPackage: Package,
        completion: @escaping (Result<String, Error>) -> Void) {
            
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            // Create a document reference first
            let newDocumentRef = fdb.document(targetPackage.docPath)
            var packageCopy = targetPackage
            
            // Encode your package object into JSON and converted it to a dictionary
            let jsonData = try encoder.encode(packageCopy)
            let dictionary = try jsonData.toDictionary()
            
            // Upload the JSON dictionary to Firestore
            newDocumentRef.setData(dictionary) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(newDocumentRef.path))
                }
            }
        } catch {
            // Handle encoding errors
            completion(.failure(error))
        }
    }
    
    // MARK: - Update user -
    func updateUserPackages(
        userId: String,
        packageType: PackageCollection,
        docPath: String,
        perform operation: PackageOperation,
        completion: @escaping () -> Void
    ) {
        
        let userRef = fdb.collection("users").document(userId)
        var fieldOperation = FieldValue.arrayUnion([docPath])
        
        switch operation {
        case .add:
            fieldOperation = FieldValue.arrayUnion([docPath])
        case .remove:
            fieldOperation = FieldValue.arrayRemove([docPath])
        }
        
        userRef.updateData([packageType.rawValue: fieldOperation ]) { error in
            if let error = error {
                print("Error updating user: \(error)")
            } else {
                completion()
            }
        }
    }
    
    // MARK: - Update package -
    func updatePackage(
        infoToUpdate newValue: String,
        docPath: String,
        toPath path: PackageFieldPath,
        perform operation: PackageOperation,
        completion: @escaping () -> Void
    ) {
        
        let packageRef = fdb.document(docPath)
        let fieldPath = "info.\(path.rawValue)"
        
        var fieldOperation = FieldValue.arrayUnion([newValue])
        switch operation {
        case .add:
            fieldOperation = FieldValue.arrayUnion([newValue])
        case .remove:
            fieldOperation = FieldValue.arrayRemove([newValue])
        }
        
        packageRef.updateData([fieldPath: fieldOperation ]) { error in
            if let error = error {
                print("Error updating package: \(error)")
            } else {
                completion()
            }
        }
    }
    
    // MARK: - Update package just for chat -
    func updatePackage(
        infoToUpdate newValue: String,
        docPath: String,
        toPath path: String,
        perform operation: PackageOperation,
        completion: @escaping () -> Void
    ) {
        
        let packageRef = fdb.document(docPath)
        let fieldPath = path
        
        packageRef.updateData([fieldPath: newValue ]) { error in
            if let error = error {
                print("Error updating package: \(error)")
            } else {
                completion()
            }
        }
    }
    
    // MARK: - Fetch favorite packages -
    func fetchUser(
        _ userId: String) async throws -> User {
        do {
            let document = try await fdb.collection("users").document(userId).getDocument()
            
            guard document.exists, let userData = document.data() else {
                throw FirestoreError.userNotFound
            }
            
            let jsonData = try JSONSerialization.data(withJSONObject: userData, options: [])
            let user = try JSONDecoder().decode(User.self, from: jsonData)
            return user
            
        } catch {
            print("fetch user \(error)")
            throw error // Rethrow the error for handling at the call site
        }
    }

    func fetchPackages(
        withIDs docPaths: [String]) async throws -> [Package] {
        do {
            var packages = [Package]()
            try await withThrowingTaskGroup(of: Package?.self) { group in
                for docPath in docPaths {
                    group.addTask {
                        return try await self.fetchPackage(withID: docPath)
                    }
                }
                
                for try await package in group {
                    if let package = package {
                        packages.append(package)
                    }
                }
            }
            return packages
        } catch {
            print("fetch Fav \(error)")
            throw error // Rethrow the error for handling at the call site
        }
    }

    // Helper function to fetch a single package
    func fetchPackage(
        withID docPath: String) async throws -> Package? {
        do {
            
            let documentRef = fdb.document(docPath)
            
            let document = try await documentRef.getDocument()
            
            guard let packageData = document.data(), document.exists else {
                // Handle the case where the document doesn't exist or has no data
                throw NSError(
                    domain: "PackageError",
                    code: 0,
                    userInfo: [NSLocalizedDescriptionKey: "No data found for package"])
            }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: packageData, options: [])
                let package = try JSONDecoder().decode(Package.self, from: jsonData)
                print("\(package)")
                return package
            } catch {
                // Handle JSON serialization or decoding error
                print("JSON: \(error)")
                
                throw error
            }
        } catch {
            print("Firestore: \(error)")
            
            // Handle Firestore document fetch error
            throw error
        }
    }
    
    // Fetch package for multi-user
    func fetchPackageMU(
        withID docPath: String) async throws -> Package? {
            
            do {
                
                let path = docPath.components(separatedBy: "/").last
                
                let documentRef = fdb.document("sessionPackages/" + (path ?? ""))
                
                let document = try await documentRef.getDocument()
                
                guard let packageData = document.data(), document.exists else {
                    // Handle the case where the document doesn't exist or has no data
                    throw NSError(
                        domain: "PackageError",
                        code: 0,
                        userInfo: [NSLocalizedDescriptionKey: "No data found for package"])
                }
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: packageData, options: [])
                    let package = try JSONDecoder().decode(Package.self, from: jsonData)
                    print("\(package)")
                    return package
                } catch {
                    // Handle JSON serialization or decoding error
                    print("JSON: \(error)")
                    
                    throw error
                }
                
            } catch {
                print("Firestore: \(error)")
                
                // Handle Firestore document fetch error
                throw error
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
//                    // Decode the JSON Data to a Package02 object
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

// MARK: - Convert to dictionary -
extension Encodable {
    func toDictionary() throws -> [String: Any] {
        
        let data = try JSONEncoder().encode(self)
        
        guard let dictionary = try JSONSerialization.jsonObject(
            with: data,
            options: .allowFragments) as? [String: Any] else {
            
            throw NSError(
                domain: "",
                code: 100,
                userInfo: [NSLocalizedDescriptionKey: "Could not convert JSON data to dictionary"])
        }
        return dictionary
    }
}

extension Data {
    
    func toDictionary() throws -> [String: Any] {
        
        guard let dictionary = try JSONSerialization.jsonObject(
            with: self,
            options: .allowFragments) as? [String: Any] else {
            
            throw NSError(
                domain: "",
                code: 100,
                userInfo: [NSLocalizedDescriptionKey: "Could not convert JSON data to dictionary"])
        }
        return dictionary
    }
}

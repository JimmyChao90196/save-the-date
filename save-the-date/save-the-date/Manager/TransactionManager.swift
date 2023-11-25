//
//  TransactionManager.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/23.
//

import Foundation
import FirebaseFirestore
import UIKit

extension FirestoreManager {
    
    // Listener
    func modulesListener(packageId: String, onChange: @escaping ([PackageModule]) -> Void) {
        
        let packageDocument = fdb.collection("sessionPackages").document(packageId)
        
        packageDocument.addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            do {
                let package = try Firestore.Decoder().decode(Package.self, from: data)
                print("Current data: \(package.weatherModules.sunny)")
                onChange(package.weatherModules.sunny)
            } catch let error {
                print("Error decoding package: \(error)")
            }
        }
    }
    
    // Lock the module
    func updateModulesWithTrans(
        packageId: String,
        moduleIndex: Int,
        time: TimeInterval,
        currentModules: [PackageModule],
        localPackage: Package,
        completion: ((Package) -> Void)?
    ) {
        
        let packageDocument = fdb.collection("sessionPackages").document(packageId)
        var newPackage = Package()
        fdb.runTransaction({ (transaction, errorPointer) -> Any? in
            let packageSnapshot: DocumentSnapshot
            do {
                try packageSnapshot = transaction.getDocument(packageDocument)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            // Convert Firestore data to JSON and then deserialize
            guard let packageData = packageSnapshot.data(),
                  let jsonData = try? JSONSerialization.data(withJSONObject: packageData, options: []),
                  
                    let package = try? JSONDecoder().decode(Package.self, from: jsonData) else {
                let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Unable to deserialize package data."
                ])
                errorPointer?.pointee = error
                return nil
            }
            
            newPackage = package
            
            let newIndex = newPackage.weatherModules.sunny.firstIndex {
                $0.lockInfo.timestamp == time
            }
            
            let localIndex = currentModules.firstIndex {
                $0.lockInfo.timestamp == time
            }
            
            // Only change target module
            newPackage.weatherModules.sunny[newIndex ?? 0] = currentModules[localIndex ?? 0]
            newPackage.weatherModules.sunny[newIndex ?? 0].lockInfo.userId = ""
            
            // Commit the changes
            transaction.updateData([
                "weatherModules.sunny": newPackage.weatherModules.sunny.map({ try? $0.toDictionary() }),
                "info.version": package.info.version
            ], forDocument: packageDocument)
            return nil
        }, completion: { _, error in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
                completion?(newPackage)
            }
        })
    }
    
    func appendModuleWithTrans(
        packageId: String,
        userId: String,
        with targetModule: PackageModule) {
            
            let packageDocument = fdb.collection("sessionPackages").document(packageId)
            
            fdb.runTransaction({ (transaction, errorPointer) -> Any? in
                let packageSnapshot: DocumentSnapshot
                do {
                    try packageSnapshot = transaction.getDocument(packageDocument)
                } catch let fetchError as NSError {
                    errorPointer?.pointee = fetchError
                    return nil
                }
                
                // Convert Firestore data to JSON and then deserialize
                guard let packageData = packageSnapshot.data(),
                      let jsonData = try? JSONSerialization.data(withJSONObject: packageData, options: []),
                      var package = try? JSONDecoder().decode(Package.self, from: jsonData) else {
                    let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [
                        NSLocalizedDescriptionKey: "Unable to deserialize package data."
                    ])
                    errorPointer?.pointee = error
                    return nil
                }
                
                // Lock the module for editing
                package.weatherModules.sunny.append(targetModule)
                
                // Commit the changes
                transaction.updateData([
                    "weatherModules.sunny": package.weatherModules.sunny.map {
                        try? $0.toDictionary()
                    }], forDocument: packageDocument)
                
                return nil
            }, completion: { _, error in
                if let error = error {
                    print("Transaction failed: \(error)")
                } else {
                    print("Transaction successfully committed!")
                }
            })
        }
    
    // MARK: - Swap modules with trans -
    func swapModulesWithTrans(
        packageId: String,
        sourceIndex: Int,
        destIndex: Int,
        with localPackage: Package,
        completion: ((Package) -> Void)?
    ) {
        let packageDocument = fdb.collection("sessionPackages").document(packageId)
        
        fdb.runTransaction({ (transaction, errorPointer) -> Any? in
            let packageSnapshot: DocumentSnapshot
            do {
                try packageSnapshot = transaction.getDocument(packageDocument)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let packageData = packageSnapshot.data(),
                  let jsonData = try? JSONSerialization.data(withJSONObject: packageData, options: []),
                  var package = try? JSONDecoder().decode(Package.self, from: jsonData) else {
                let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Unable to deserialize package data."
                ])
                errorPointer?.pointee = error
                return nil
            }
            
            // Check for version consistency
            let fetchedVersion = package.info.version
            print("remote package version: \(fetchedVersion)")
            print("local package version: \(localPackage.info.version)")
            
            // Version inconsistency, abort swap action if needed
            if fetchedVersion != localPackage.info.version {
                completion?(package)
            } else {
                // Swap the modules
                package.weatherModules.sunny.swapAt(sourceIndex, destIndex)
                package.info.version += 1
                completion?(package)
            }
            
            // Commit the changes
            transaction.updateData([
                "weatherModules.sunny": package.weatherModules.sunny.map({ try? $0.toDictionary() }),
                "info.version": package.info.version
            ], forDocument: packageDocument)
            return nil
            
        }, completion: { _, error in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
            }
        })
    }
    
    // MARK: - Delete with transaction
    func deleteModuleWithTrans(
        packageId: String,
        targetIndex: Int,
        with localPackage: Package,
        completion: ((Package) -> Void)?
    ) {
        let packageDocument = fdb.collection("sessionPackages").document(packageId)
        
        fdb.runTransaction({ (transaction, errorPointer) -> Any? in
            let packageSnapshot: DocumentSnapshot
            do {
                try packageSnapshot = transaction.getDocument(packageDocument)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let packageData = packageSnapshot.data(),
                  let jsonData = try? JSONSerialization.data(withJSONObject: packageData, options: []),
                  var package = try? JSONDecoder().decode(Package.self, from: jsonData) else {
                let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Unable to deserialize package data."
                ])
                errorPointer?.pointee = error
                return nil
            }
            
            // Check for version consistency
            let fetchedVersion = package.info.version
            print("remote package version: \(fetchedVersion)")
            print("local package version: \(localPackage.info.version)")
            
            // Version inconsistency, abort delete action if needed
            if fetchedVersion != localPackage.info.version {
                completion?(package)
                
            } else {
                // delete the modules
                package.weatherModules.sunny.remove(at: targetIndex)
                package.info.version += 1
                completion?(package)
            }
            
            // Commit the changes
            transaction.updateData([
                "weatherModules.sunny": package.weatherModules.sunny.map { try? $0.toDictionary() },
                "info.version": package.info.version
            ], forDocument: packageDocument)
            return nil
            
        }, completion: { _, error in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
            }
        })
    }
    
    // MARK: - Lock module with trans
    func lockModuleWithTrans(
        packageId: String,
        userId: String,
        targetIndex: Int,
        with localPackage: Package,
        completion: ((Package) -> Void)?
    ) {
        let packageDocument = fdb.collection("sessionPackages").document(packageId)
        
        fdb.runTransaction({ (transaction, errorPointer) -> Any? in
            let packageSnapshot: DocumentSnapshot
            do {
                try packageSnapshot = transaction.getDocument(packageDocument)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let packageData = packageSnapshot.data(),
                  let jsonData = try? JSONSerialization.data(withJSONObject: packageData, options: []),
                  var package = try? JSONDecoder().decode(Package.self, from: jsonData) else {
                let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Unable to deserialize package data."
                ])
                errorPointer?.pointee = error
                return nil
            }
            
            // Check for version consistency
            let fetchedVersion = package.info.version
            print("remote package version: \(fetchedVersion)")
            print("local package version: \(localPackage.info.version)")
            
            // Version inconsistency, fetch newest data and apply to local
            if fetchedVersion != localPackage.info.version {
                completion?(package)
                
            } else {
                // update the modules
                package.weatherModules.sunny[targetIndex].lockInfo.userId = userId
                // package.weatherModules.sunny[targetIndex].lockInfo.timestamp = Date().timeIntervalSince1970
                package.info.version += 1
                completion?(package)
            }
            
            // Commit the changes
            transaction.updateData([
                "weatherModules.sunny": package.weatherModules.sunny.map { try? $0.toDictionary() },
                "info.version": package.info.version
            ], forDocument: packageDocument)
            return nil
            
        }, completion: { _, error in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
            }
        })
    }
}

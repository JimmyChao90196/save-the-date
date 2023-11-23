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
        userId: String,
        currentModules: [PackageModule]) {
        
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

            // Check if the module is already locked by someone else
//            let memberlocation = package.weatherModules.sunny[moduleIndex].memberLocation
//            if memberlocation.userId != "" && memberlocation.userId != userId {
//                // Module is locked by someone else
//                return
//            }

            // Lock the module for editing
            var sunnyModules = currentModules
            print("sunnyModules: \(sunnyModules)")
            sunnyModules[moduleIndex].memberLocation = MemberLocation(
                userId: userId,
                timestamp: Date().timeIntervalSince1970)
            package.weatherModules.sunny = sunnyModules

            // Commit the changes
            transaction.updateData([
                "weatherModules.sunny": package.weatherModules.sunny.map({ try? $0.toDictionary()
                })], forDocument: packageDocument)
            return nil
        }) { _, error in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
            }
        }
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

            // Check if the module is already locked by someone else
//            let memberlocation = package.weatherModules.sunny[moduleIndex].memberLocation
//            if memberlocation.userId != "" && memberlocation.userId != userId {
//                // Module is locked by someone else
//                return
//            }

            // Lock the module for editing
            package.weatherModules.sunny.append(targetModule)

            // Commit the changes
            transaction.updateData([
                "weatherModules.sunny": package.weatherModules.sunny.map({ try? $0.toDictionary()})], forDocument: packageDocument)
            
            return nil
        }) { _, error in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
            }
        }
    }

}

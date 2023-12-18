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
    func modulesListener(
        docPath: String,
        onChange: @escaping (Package) -> Void) -> ListenerRegistration? {
            
            let packageDocument = fdb.document(docPath)
            
            let listenerRigsteration = packageDocument.addSnapshotListener { documentSnapshot, error in
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
                    
                    onChange(package)
                    
                } catch let error {
                    print("Error decoding package: \(error)")
                }
            }
            return listenerRigsteration
        }
    
    // Lock the module
    func updateModulesWithTrans(
        docPath: String,
        time: TimeInterval,
        when weatherState: WeatherState,
        localSunnyModules: [PackageModule],
        localRainyModules: [PackageModule],
        completion: ((Package) -> Void)?
    ) {
        
        let packageDocument = fdb.document(docPath)
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
            var path = ""
            var value = [[String: Any]?]()
            
            if weatherState == .sunny {
                
                let newIndex = newPackage.weatherModules.sunny.firstIndex {
                    $0.lockInfo.timestamp == time
                }
                
                let localIndex = localSunnyModules.firstIndex {
                    $0.lockInfo.timestamp == time
                }
                
                // Only change target module
                newPackage.weatherModules.sunny[newIndex ?? 0] =
                localSunnyModules[localIndex ?? 0]
                newPackage.weatherModules.sunny[newIndex ?? 0].lockInfo.userId = ""
                newPackage.weatherModules.sunny[newIndex ?? 0].lockInfo.userName = ""
                
                path = "weatherModules.sunny"
                value = newPackage.weatherModules.sunny.map({ try? $0.toDictionary() })
                
            } else {
                
                let newIndex = newPackage.weatherModules.rainy.firstIndex {
                    $0.lockInfo.timestamp == time
                }
                
                let localIndex = localRainyModules.firstIndex {
                    $0.lockInfo.timestamp == time
                }
                
                // Only change target module
                newPackage.weatherModules.rainy[newIndex ?? 0] =
                localRainyModules[localIndex ?? 0]
                newPackage.weatherModules.rainy[newIndex ?? 0].lockInfo.userId = ""
                newPackage.weatherModules.rainy[newIndex ?? 0].lockInfo.userName = ""
                
                path = "weatherModules.rainy"
                value = newPackage.weatherModules.rainy.map({ try? $0.toDictionary() })
            }
            
            // Commit the changes
            transaction.updateData([path: value], forDocument: packageDocument)
            
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
        docPath: String,
        userId: String,
        isNewDay: Bool,
        when weatherState: WeatherState,
        with targetModule: PackageModule) {
            
            let packageDocument = fdb.document(docPath)
            
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
                
                if weatherState == .sunny {
                    
                    if isNewDay {
                        let uniqueSet = Set(package.weatherModules.sunny.compactMap { $0.day })
                        let module = PackageModule(day: uniqueSet.count)
                        package.weatherModules.sunny.append(module)
                    } else {
                        package.weatherModules.sunny.append(targetModule)
                    }
                    
                    // Commit the changes
                    transaction.updateData([
                        "weatherModules.sunny": package.weatherModules.sunny.map {
                            try? $0.toDictionary()
                        }], forDocument: packageDocument)
                } else {
                    
                    if isNewDay {
                        let uniqueSet = Set(package.weatherModules.rainy.compactMap { $0.day })
                        let module = PackageModule(day: uniqueSet.count)
                        package.weatherModules.rainy.append(module)
                    } else {
                        package.weatherModules.rainy.append(targetModule)
                    }
                    
                    // Commit the changes
                    transaction.updateData([
                        "weatherModules.rainy": package.weatherModules.rainy.map {
                            try? $0.toDictionary()
                        }], forDocument: packageDocument)
                }
                
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
        docPath: String,
        sourceIndex: Int,
        destIndex: Int,
        with localPackage: Package,
        when weatherState: WeatherState,
        completion: ((Package) -> Void)?
    ) {
        
        let packageDocument = fdb.document(docPath)
        
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
            
            var path = ""
            var value = [[String: Any]?]()
            
            switch weatherState {
            case .sunny:
                // Version inconsistency, abort swap action if needed
                if fetchedVersion != localPackage.info.version {
                    completion?(package)
                } else {
                    // Swap the modules
                    package.weatherModules.sunny.swapAt(sourceIndex, destIndex)
                    package.info.version += 1
                    completion?(package)
                }
                path = "weatherModules.sunny"
                value = package.weatherModules.sunny.map {try? $0.toDictionary()}
            case .rainy:
                // Version inconsistency, abort swap action if needed
                if fetchedVersion != localPackage.info.version {
                    completion?(package)
                } else {
                    // Swap the modules
                    package.weatherModules.rainy.swapAt(sourceIndex, destIndex)
                    package.info.version += 1
                    completion?(package)
                }
                path = "weatherModules.rainy"
                value = package.weatherModules.rainy.map {try? $0.toDictionary()}
            }
            
            // Commit the changes
            transaction.updateData([
                path: value,
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
        docPath: String,
        time: TimeInterval,
        targetIndex: Int,
        with localPackage: Package,
        when weatherState: WeatherState,
        completion: ((Package) -> Void)?
    ) {
        
        let packageDocument = fdb.document(docPath)
        
        var newPackage = Package()
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
                  let package = try? JSONDecoder().decode(Package.self, from: jsonData) else {
                let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Unable to deserialize package data."
                ])
                errorPointer?.pointee = error
                return nil
            }
            
            // Check for version consistency
            // let fetchedVersion = package.info.version
            newPackage = package
            var path = ""
            var value = [[String: Any]?]()
            
            switch weatherState {
            case .sunny:
                guard let newIndex = newPackage.weatherModules.sunny.firstIndex(where: {
                    $0.lockInfo.timestamp == time }) else { return }
                
                // delete the modules
                newPackage.weatherModules.sunny.remove(at: newIndex)
                newPackage.info.version += 1
                
                path = "weatherModules.sunny"
                value = newPackage.weatherModules.sunny.map {try? $0.toDictionary()}
                
            case .rainy:
                guard let newIndex = newPackage.weatherModules.rainy.firstIndex(where: {
                    $0.lockInfo.timestamp == time }) else { return }
                
                // delete the modules
                newPackage.weatherModules.rainy.remove(at: newIndex)
                newPackage.info.version += 1
                
                path = "weatherModules.rainy"
                value = newPackage.weatherModules.rainy.map {try? $0.toDictionary()}
            }
            
            // Commit the changes
            transaction.updateData([
                path: value,
                "info.version": newPackage.info.version
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
    
    // MARK: - Lock module with trans
    func lockModuleWithTrans(
        docPath: String,
        userId: String,
        userName: String,
        time: TimeInterval,
        when weatherState: WeatherState,
        completion: ((Package, Int, Bool) -> Void)?
    ) {
        
        let packageDocument = fdb.document(docPath)
        
        var newPackage = Package()
        var rawIndex = 0
        var isLate = false
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
                  let package = try? JSONDecoder().decode(Package.self, from: jsonData) else {
                let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Unable to deserialize package data."
                ])
                errorPointer?.pointee = error
                return nil
            }

            // New package
            newPackage = package
            var path = ""
            var value = [[String: Any]?]()
            
            switch weatherState {
            case .sunny:
                guard let newIndex = newPackage.weatherModules.sunny.firstIndex(where: {
                    $0.lockInfo.timestamp == time }) else { return }
                rawIndex = newIndex
                
                // update the modules
                let oldID = newPackage.weatherModules.sunny[newIndex].lockInfo.userId
                
                if oldID != "" && oldID != userId {
                    isLate = true
                    return
                } else {
                    newPackage.weatherModules.sunny[newIndex].lockInfo.userId = userId
                    newPackage.weatherModules.sunny[newIndex].lockInfo.userName = userName
                    // newPackage.info.version += 1
                }
                
                path = "weatherModules.sunny"
                value = newPackage.weatherModules.sunny.map { try? $0.toDictionary() }
                
            case .rainy:
                guard let newIndex = newPackage.weatherModules.rainy.firstIndex(where: {
                    $0.lockInfo.timestamp == time }) else { return }
                rawIndex = newIndex
                
                // update the modules
                let oldID = newPackage.weatherModules.rainy[newIndex].lockInfo.userId
                
                if oldID != "" && oldID != userId {
                    isLate = true
                    return
                } else {
                    newPackage.weatherModules.rainy[newIndex].lockInfo.userId = userId
                    newPackage.weatherModules.rainy[newIndex].lockInfo.userName = userName
                    // newPackage.info.version += 1
                }
                
                path = "weatherModules.rainy"
                value = newPackage.weatherModules.rainy.map { try? $0.toDictionary()}
                
            }
            
            // Commit the changes
            transaction.updateData([
                path: value,
                "info.version": newPackage.info.version
            ], forDocument: packageDocument)
            return nil
            
        }, completion: { _, error in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
                completion?(newPackage, rawIndex, isLate)
            }
        })
    }
}

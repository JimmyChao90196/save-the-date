//
//  PackageManager.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/15.
//

import Foundation
import UIKit

class PackageManager {
    
    static let shared = PackageManager()
    
    var packageModules = [PackageModule]()
    
    func movePackage(from source: IndexPath, to destination: IndexPath) {
        let movedObject = packageModules[source.row]
        packageModules.remove(at: source.row)
        packageModules.insert(movedObject, at: destination.row)
    }
    
    func deletePackage(at indexPath: IndexPath) {
        packageModules.remove(at: indexPath.row)
    }
    
    func addPackage(_ package: PackageModule) {
        packageModules.append(package)
    }
    
    func reviceLocation( replace indexPathToEdit: IndexPath, with location: Location) {
        packageModules[indexPathToEdit.row].location = location
    }
    
    func reviceTransportation(relplace indexPathToEdit: IndexPath, with transportation: Transportation) {
        packageModules[indexPathToEdit.row].transportation = transportation
    }
    
}

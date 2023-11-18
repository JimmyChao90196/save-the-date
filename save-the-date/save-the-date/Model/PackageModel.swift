//
//  PlaceModel.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/16.
//

import Foundation
import UIKit

struct Package: Codable {
    var info: Info
    var packageModules: [PackageModule]
    
    var dictionary: [String: Any] {
        var dict = [String: Any]()
        dict["info"] = ["title": info.title,
                        "author": info.author,
                        "rate": info.rate,
                        "state": info.state]
        
        dict["packageModules"] = packageModules.map { $0.dictionary }
        
        return dict
    }
    
    // Original init
    init(info: Info, packageModules: [PackageModule]) {
        self.info = info
        self.packageModules = packageModules
    }
    
    // Package conversion
    init(convertFrom dictionary: [String: Any]) {
        let infoDict = dictionary["info"] as? [String: Any] ?? [:]
        let packageModulesArray = dictionary["packageModules"] as? [[String: Any]] ?? []
        
        let info = Info(
            title: infoDict["title"] as? String ?? "",
            author: infoDict["author"] as? String ?? "",
            rate: infoDict["rate"] as? Double ?? 0,
            state: infoDict["state"] as? String ?? ""
        )
        
        let packageModules = packageModulesArray.map { moduleDict -> PackageModule in
            let locationDict = moduleDict["location"] as? [String: Any] ?? [:]
            let transportationDict = moduleDict["transportation"] as? [String: Any] ?? [:]
            
            let location = Location(
                name: locationDict["name"] as? String ?? "",
                shortName: locationDict["shortName"] as? String ?? "",
                identifier: locationDict["identifier"] as? String ?? "",
                coordinate: locationDict["coordinate"] as? [String: Double] ?? ["lat": 0.0, "lng": 0.0]
            )
            
            let transportation = Transportation(
                transpIcon: transportationDict["transpIcon"] as? String ?? "",
                travelTime: transportationDict["travelTime"] as? TimeInterval ?? 0.0
            )
            
            return PackageModule(location: location, transportation: transportation)
        }
        
        self.info = info
        self.packageModules = packageModules
    }
}

// MARK: - Package module -
struct PackageModule: Codable {
    var location: Location
    var transportation: Transportation
    
    var dictionary: [String: Any] {
        return ["location": location.dictionary,
                "transportation": transportation.dictionary]
    }
}

// MARK: - Location -
struct Location: Codable {
    var name: String
    var shortName: String
    var identifier: String
    var coordinate: [String: Double]
    
    init(name: String,
         shortName: String,
         identifier: String,
         coordinate: [String: Double] = ["lat": 0.0, "lng": 0.0]) {
        self.name = name
        self.shortName = shortName
        self.identifier = identifier
        self.coordinate = coordinate
    }
    
    var dictionary: [String: Any] {
        return ["name": name,
                "shortName": shortName,
                "identifier": identifier,
                "coordinate": coordinate]
    }
}

// MARK: - Transportation -
struct Transportation: Codable {
    var transpIcon: String
    var travelTime: TimeInterval
    
    init(transpIcon: String, travelTime: TimeInterval = 0.0) {
        self.transpIcon = transpIcon
        self.travelTime = travelTime
    }
    
    var dictionary: [String: Any] {
        return ["transpIcon": transpIcon,
            "travelTime": travelTime]
    }
}

// MARK: - Info -
struct Info: Codable {
    var title: String
    var author: String
    var rate: Double
    var state: String
    
    init(title: String = "packageTitle",
         author: String = "Jimmy Chao",
         rate: Double = 5,
         state: String = "published") {
        self.title = title
        self.author = author
        self.rate = rate
        self.state = state
    }
}

// MARK: - Package state
enum PackageState: String {
    case publishedState = "published"
    case privateState = "private"
    case forkedState = "forked"
    case favoriteState = "favorite"
    case draftState = "draft"
}

enum PackageCollection: String {
    case publishedColl = "publishedPackages"
    case privateColl = "privatePackages"
    case forkedColl = "forkedPackages"
    case favoriteColl = "favoritePackages"
    case draftColl = "draftPackages"
}

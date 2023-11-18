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

}

// MARK: - Package module -
struct PackageModule: Codable {
    var location: Location
    var transportation: Transportation
    
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

}

// MARK: - Transportation -
struct Transportation: Codable {
    var transpIcon: String
    var travelTime: TimeInterval
    
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

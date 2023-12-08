//
//  PlaceModel.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/16.
//

import Foundation
import UIKit

// MARK: - Overall package -
struct Package: Codable, Hashable {
    
    var info: Info
    var weatherModules: WeatherModules
    var regionTags: [String]
    var docPath: String
    var chatDocPath: String
    var photoURL: String
    
    // init
    init(info: Info = Info(),
         weatherModules: WeatherModules = WeatherModules(sunny: [], rainy: []),
         regionTags: [String] = [],
         docPath: String = "",
         chatDocPath: String = "",
         photoURL: String = ""
    ) {
        self.info = info
        self.weatherModules = weatherModules
        self.regionTags = regionTags
        self.docPath = docPath
        self.chatDocPath = chatDocPath
        self.photoURL = photoURL
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(docPath)
    }
    
    static func == (lhs: Package, rhs: Package) -> Bool {
        lhs.docPath == rhs.docPath
    }
}

// MARK: - Package module -
struct PackageModule: Codable, Equatable {
    
    static func == (lhs: PackageModule, rhs: PackageModule) -> Bool {
        lhs.date == rhs.date
    }
    
    var location: Location
    var transportation: Transportation
    var day: Int
    var date: TimeInterval
    var version: Int
    var lockInfo: LockInfo
    
    init(location: Location = Location(address: "None", shortName: "None", identifier: "None"),
         transportation: Transportation = Transportation(transpIcon: "plus.viewfinder", travelTime: 0.0),
         day: Int = 1,
         date: TimeInterval = Date().timeIntervalSince1970,
         version: Int = 0,
         lockInfo: LockInfo = LockInfo(userId: "", timestamp: Date().timeIntervalSince1970)
    ) {
        self.location = location
        self.transportation = transportation
        self.day = day
        self.date = date
        self.version = version
        self.lockInfo = lockInfo
    }
}

// MARK: - Lock Info -
struct LockInfo: Codable {
    var userId: String
    var timestamp: TimeInterval
}

// MARK: - WeatherModules
struct WeatherModules: Codable {
    var sunny: [PackageModule]
    var rainy: [PackageModule]
}

// MARK: - Location -
struct Location: Codable {
    var address: String
    var shortName: String
    var identifier: String
    var coordinate: [String: Double]
    
    init(address: String,
         shortName: String,
         identifier: String,
         coordinate: [String: Double] = ["lat": 0.0, "lng": 0.0]) {
        self.address = address
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
    var author: [String]
    var authorEmail: [String]
    var id: String
    var rate: Double
    var state: String
    var forkedFrom: String
    var forkedBy: [String]
    var likedBy: [String]
    var version: Int
    
    init(title: String = "packageTitle",
         author: [String] = ["red"],
         authorEmail: [String] = ["red@gmail.com"],
         id: String = "none",
         rate: Double = 5.0,
         state: String = "published",
         forkedFrom: String = "none",
         forkedBy: [String] = [String](),
         likedBy: [String] = [String](),
         version: Int = 0
    ) {
        self.title = title
        self.author = author
        self.authorEmail = authorEmail
        self.id = id
        self.rate = rate
        self.state = state
        self.forkedFrom = forkedFrom
        self.forkedBy = forkedBy
        self.likedBy = likedBy
        self.version = version
    }
}

// MARK: - Package state
enum PackageState: String {
    case publishedState = "published"
    case privateState = "private"
    case forkedState = "forked"
    case favoriteState = "favorite"
    case draftState = "draft"
    case sessitonState = "session"
}

enum PackageCollection: String {
    case publishedColl = "publishedPackages"
    case privateColl = "privatePackages"
    case forkedColl = "forkedPackages"
    case favoriteColl = "favoritePackages"
    case draftColl = "draftPackages"
    case sessionColl = "sessionPackages"
    
}

enum PackageFieldPath: String {
    case forkedFrom
    case likedBy
    case draft
    case author
    case authorEmail
}

enum PackageOperation: String {
    case add
    case remove
}

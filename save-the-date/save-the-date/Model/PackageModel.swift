//
//  PlaceModel.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/16.
//

import Foundation
import UIKit

// MARK: - Overall package -
struct Package: Codable {
    var info: Info
    // var packageModules: [PackageModule]
    var weatherModules: WeatherModules
    var proxyLocatinon: String
    
    // init
    init(info: Info = Info(),
         weatherModules: WeatherModules = WeatherModules(sunny: [], rainy: []),
         proxyLocatinon: String = "none") {
        self.info = info
        self.weatherModules = weatherModules
        self.proxyLocatinon = proxyLocatinon
    }
}

// MARK: - Package module -
struct PackageModule: Codable {
    var location: Location
    var transportation: Transportation
    var day: Int
    var date: TimeInterval
    
    init(location: Location = Location(name: "None", shortName: "None", identifier: "None"),
         transportation: Transportation = Transportation(transpIcon: "plus.viewfinder", travelTime: 0.0),
         day: Int = 1,
         date: TimeInterval = Date().timeIntervalSince1970) {
        self.location = location
        self.transportation = transportation
        self.day = day
        self.date = date
    }
}

// MARK: - WeatherModules
struct WeatherModules: Codable {
    var sunny: [PackageModule]
    var rainy: [PackageModule]
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
    var authorEmail: String
    var id: String
    var rate: Double
    var state: String
    var forkedFrom: String
    var forkedBy: [String]
    var likedBy: [String]
    
    init(title: String = "packageTitle",
         authorEmail: String = "jimmy@gmail.com",
         id: String = "none",
         rate: Double = 5.0,
         state: String = "published",
         forkedFrom: String = "none",
         forkedBy: [String] = [String](),
         likedBy: [String] = [String]()) {
        self.title = title
        self.authorEmail = authorEmail
        self.id = id
        self.rate = rate
        self.state = state
        self.forkedFrom = forkedFrom
        self.forkedBy = forkedBy
        self.likedBy = likedBy
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

enum PackageFieldPath: String {
    case forkedFrom
    case likedBy
    case draft
}

enum PackageOperation: String {
    case add
    case remove
}

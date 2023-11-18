//
//  PlaceModel.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/16.
//

import Foundation
import UIKit

struct Package {
    var info: Info
    var packageModules: [PackageModule]
}

struct PackageModule {
    
    var location: Location
    var transportation: Transportation
}

struct Location {
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

struct Transportation {
    var transpIcon: String
    var travelTime: TimeInterval
    
    init(transpIcon: String, travelTime: TimeInterval = 0.0) {
        self.transpIcon = transpIcon
        self.travelTime = travelTime
    }
}

struct Info {
    var title: String
    var author: String
    var rate: Int
    var state: String
}

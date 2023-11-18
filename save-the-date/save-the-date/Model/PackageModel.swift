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
    
    var dictionary: [String: Any] {
        var dict = [String: Any]()
        dict["info"] = ["title": info.title,
                        "author": info.author,
                        "rate": info.rate,
                        "state": info.state]
        
        dict["packageModules"] = packageModules.map { $0.dictionary }
        
        return dict
    }
}

struct PackageModule {
    var location: Location
    var transportation: Transportation
    
    var dictionary: [String: Any] {
        return ["location": location.dictionary,
                "transportation": transportation.dictionary]
    }
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
    
    var dictionary: [String: Any] {
        return ["name": name,
                "shortName": shortName,
                "identifier": identifier,
                "coordinate": coordinate]
    }
}

struct Transportation {
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

struct Info {
    var title: String
    var author: String
    var rate: Int
    var state: String
    
    init(title: String = "packageTitle",
         author: String = "Jimmy Chao",
         rate: Int = 5,
         state: String = "published") {
        self.title = title
        self.author = author
        self.rate = rate
        self.state = state
    }
}

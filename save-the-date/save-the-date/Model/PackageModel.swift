//
//  PlaceModel.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/16.
//

import Foundation
import UIKit

struct PackageModule {
    var location: Location
    var transportation: Transportation
}

struct Location {
    var name: String
    var shortName: String
    var identifier: String
}

struct Transportation {
    var transpIcon: String
}

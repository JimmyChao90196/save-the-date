//
//  ExploreModel.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/12/1.
//

import Foundation

enum CityModel {
    
    case taipei
    case taichung
    
    var district: [String] {
        switch self {
        case .taipei:
            return ["", "", "", "",]
            
        case .taichung:
            return [""]
        }
    }
}

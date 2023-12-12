//
//  TranspManager.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/16.
//

import Foundation
import UIKit
import MapKit
    
enum TranspManager: String, CaseIterable {
    case car
    case bus
    case train
    case metro
    case plane
    case ship
    case bicycle
    case walk
    
    static func from(transIcon: String) -> TranspManager? {
        return TranspManager.allCases.first { $0.transIcon == transIcon }
    }
    
    var transIcon: String {
        switch self {
        case .car: return "car"
            
        case .bus: return "bus"
            
        case .train: return "train.side.front.car"
            
        case .metro: return "tram.fill"
            
        case .plane: return "airplane"
            
        case .ship: return "ferry"
            
        case .bicycle: return "bicycle"
            
        case .walk: return "figure.walk"
        }
    }
    
    var transpType: MKDirectionsTransportType {
        switch self {
        case .car:
            return .automobile
        case .bus:
            return .automobile
        case .train:
            return .automobile
        case .metro:
            return .automobile
        case .plane:
            return .automobile
        case .ship:
            return .automobile
        case .bicycle:
            return .walking
        case .walk:
            return .walking
        }
    }
}

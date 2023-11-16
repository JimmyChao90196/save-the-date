//
//  TranspManager.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/16.
//

import Foundation
import UIKit
    
enum TranspManager: CaseIterable {
    case car
    case bus
    case train
    case metro
    case plane
    case ship
    case bicycle
    case walk
    
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
}

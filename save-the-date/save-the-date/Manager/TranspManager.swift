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
    
    var transIcon: UIImage {
        switch self {
        case .car:
            return UIImage(systemName: "car")!
        case .bus:
            return UIImage(systemName: "bus")!
        case .train:
            return UIImage(systemName: "train.side.front.car")!
        case .metro:
            return UIImage(systemName: "tram.fill")!
        case .plane:
            return UIImage(systemName: "airplane")!
        case .ship:
            return UIImage(systemName: "ferry")!
        case .bicycle:
            return UIImage(systemName: "bicycle")!
        case .walk:
            return UIImage(systemName: "figure.walk")!
        }
    }
    
}

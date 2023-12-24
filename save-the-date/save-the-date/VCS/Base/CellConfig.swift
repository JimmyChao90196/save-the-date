//
//  CellConfig.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/12/24.
//

import Foundation
import UIKit

struct CellClaimedByUser: CellClaimingProtocol {
    
    var userIdIsHidden: Bool = false
    
    var userIdBackgroundColor: UIColor = .black
    
    var userIdTextColor: UIColor = .white
    
    var locationViewBoarderColor: UIColor = .black
    
    var transpIconTintColor: UIColor = .lightGray
    
    var travelLabelTextColor: UIColor = .darkGray
    
    var siteTitletextColor: UIColor = .customUltraGrey
    
    var arrivedTimeLabelTextColor: UIColor = .customUltraGrey
    
    var contentViewBoarderColor: UIColor = .clear
}

struct Cellunclaimed: CellClaimingProtocol {
    
    var userIdIsHidden: Bool = true
    
    var userIdBackgroundColor: UIColor = .hexToUIColor(hex: "#AAAAAA")
    
    var userIdTextColor: UIColor = .white
    
    var locationViewBoarderColor: UIColor = .hexToUIColor(hex: "#AAAAAA")
    
    var transpIconTintColor: UIColor = .lightGray
    
    var travelLabelTextColor: UIColor = .darkGray
    
    var siteTitletextColor: UIColor = .customUltraGrey
    
    var arrivedTimeLabelTextColor: UIColor = .customUltraGrey
    
    var contentViewBoarderColor: UIColor = .clear
}

struct CellClaimedByOthers: CellClaimingProtocol {
    
    var userIdIsHidden: Bool = false
    
    var userIdBackgroundColor: UIColor = .customLightGrey
    
    var userIdTextColor: UIColor = .black
    
    var locationViewBoarderColor: UIColor = .customLightGrey
    
    var transpIconTintColor: UIColor = .customLightGrey
    
    var travelLabelTextColor: UIColor = .customLightGrey
    
    var siteTitletextColor: UIColor = .customLightGrey
    
    var arrivedTimeLabelTextColor: UIColor = .customLightGrey
    
    var contentViewBoarderColor: UIColor = .customLightGrey
}

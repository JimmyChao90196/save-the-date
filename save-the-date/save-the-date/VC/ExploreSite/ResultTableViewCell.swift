//
//  ResultTableViewCell.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/16.
//

import UIKit
import SnapKit
import GooglePlaces

class ResultTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = String(describing: ResultTableViewCell.self)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
 
}

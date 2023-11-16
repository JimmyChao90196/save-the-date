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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

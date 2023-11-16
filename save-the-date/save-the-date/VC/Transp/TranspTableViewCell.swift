//
//  TranspTableViewCell.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/16.
//

import UIKit
import SnapKit

class TranspTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = String(describing: TranspTableViewCell.self)
    
    // UI element
    var transIcon = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addTo()
        setup()
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func addTo() {
        contentView.addSubviews([transIcon])
    }
    
    private func setup() {
        transIcon.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
    }
    
    private func setupConstraint() {
        transIcon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
            make.centerY.equalToSuperview()
        }
    }
}

// MARK: - implement additional functions
extension TranspTableViewCell {
    
}

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
    var transLabel = UILabel()
    var bgView = UIView()
    
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
        contentView.addSubviews([bgView])
        bgView.addSubviews([transIcon, transLabel])
    }
    
    private func setup() {
        contentView.backgroundColor = .clear
        transIcon.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        transIcon.tintColor = .customDarkGrey
        
        transLabel.setChalkFont(20)
        transLabel.text = "Placeholder"
        transLabel.textColor = .customUltraGrey
        
        bgView.setCornerRadius(6)
            .setbackgroundColor(.standardColorCyan)
            .setBoarderColor(.black)
            .setBoarderWidth(2)
        
    }
    
    private func setupConstraint() {
        bgView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(50)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.trailing.equalToSuperview().offset(-50)
        }
        
        transLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
            make.centerY.equalToSuperview()
        }
        
        transIcon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(transLabel.snp.leading).offset(-15)
        }
    }
}

// MARK: - implement additional functions
extension TranspTableViewCell {
    
}

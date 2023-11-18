//
//  ExploreTableViewCell.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/18.
//

import UIKit
import SnapKit

class ExploreTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = String(describing: ExploreTableViewCell.self)
    
    let packageTitleLabel = UILabel()
    let packageBG = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addTo()
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func addTo() {
        contentView.addSubviews([packageBG])
        packageBG.addSubviews([packageTitleLabel])
    }
    
    private func setup() {
        packageBG.setBoarderColor(.hexToUIColor(hex: "#CCCCCC"))
            .setCornerRadius(20)
            .setBoarderWidth(1)
    }
    
    private func setupConstraint() {
        
        packageTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-20)
            make.centerX.equalToSuperview()
        }
        
        packageBG.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(30)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalTo(contentView.snp.bottom).offset(-30)
        }
    }
}

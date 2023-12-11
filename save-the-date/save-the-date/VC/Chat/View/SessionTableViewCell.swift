//
//  SessionTableViewCell.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/12/7.
//

import Foundation
import UIKit
import SnapKit

class SessionTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = String(describing: SessionTableViewCell.self)
    
    let dynamicStackView = UIStackView()
    
    // UI
    let packageTitleLabel = UILabel()
    let packageAuthor = UILabel()
    let packageBGImageView = UIImageView(image: UIImage(resource: .exploreCellBackground))
    let packageBG = UIView()
    let authorPicture = UIImageView(image: UIImage(resource: .redProfile))
    let heartImageView = UIImageView(image: UIImage(systemName: "heart"))
    
    // Divider
    let leftDivider = UIView()
    let rightDivider = UIView()
    
    // Attributes
    var onLike: ((UITableViewCell, Bool) -> Void)?
    var isLike = false
    
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
        contentView.addSubviews([packageBG])
        packageBG.addSubviews([packageTitleLabel])
    }
    
    private func setup() {
        contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        
        packageBG.setBoarderColor(.hexToUIColor(hex: "#3F3A3A"))
            .setbackgroundColor(.white)
            .setCornerRadius(20)
            .setBoarderWidth(2.5)
            .setbackgroundColor(.hexToUIColor(hex: "#87D6DD"))
        
        // Setup title
        packageTitleLabel.setbackgroundColor(.clear)
            .setFont(UIFont(name: "ChalkboardSE-Regular", size: 20)!)
            .setTextColor(.hexToUIColor(hex: "#3F3A3A"))
            .textAlignment = .center
    }
    
    private func setupConstraint() {
        
        packageBG.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.height.equalTo(50)
        }
        
        packageTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(5)
            make.trailing.equalToSuperview().offset(-5)
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
        }
    }
}

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
        packageBG.addSubviews([
            packageBGImageView,
            packageTitleLabel,
            heartImageView,
            packageAuthor,
            authorPicture,
            dynamicStackView,
            leftDivider,
            rightDivider
        ])
    }
    
    private func setup() {
        contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        
        packageBGImageView.setCornerRadius(20)
            .clipsToBounds = true
        
        packageBG.setBoarderColor(.hexToUIColor(hex: "#3F3A3A"))
            .setbackgroundColor(.white)
            .setCornerRadius(20)
            .setBoarderWidth(2.5)
        
        // Setup title
        packageTitleLabel.setbackgroundColor(.clear)
            .setFont(UIFont(name: "ChalkboardSE-Regular", size: 20)!)
            .setTextColor(.hexToUIColor(hex: "#3F3A3A"))
            .textAlignment = .center
        
        // Setup appearance
        authorPicture.clipsToBounds = true
        authorPicture.setCornerRadius(15)
            .setBoarderColor(.hexToUIColor(hex: "#CCCCCC"))
            .setBoarderWidth(2.0)
            .contentMode = .scaleAspectFit
        
        // Setup the stack view
        dynamicStackView.axis = .horizontal
        dynamicStackView.spacing = 10
        dynamicStackView.alignment = .center
        dynamicStackView.distribution = .fillProportionally
        dynamicStackView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    private func setupConstraint() {
        
//        authorPicture.snp.makeConstraints { make in
//            make.centerY.equalToSuperview()
//            make.leading.equalToSuperview().offset(10)
//            make.top.equalToSuperview().offset(20)
//            make.bottom.equalToSuperview().offset(-20)
//            make.height.equalTo(50)
//            make.width.equalTo(50)
//        }
        
//        packageAuthor.snp.makeConstraints { make in
//            make.top.equalTo(packageTitleLabel.snp.bottom).offset(10)
//            make.bottom.equalToSuperview()
//            make.leading.equalTo(leftDivider.snp.trailing).offset(10)
//            make.height.equalTo(20)
//        }
//        
//        dynamicStackView.snp.makeConstraints { make in
//            make.bottom.equalToSuperview()
//            make.leading.equalTo(packageAuthor.snp.trailing).offset(10)
//            make.trailing.equalTo(rightDivider.snp.leading).offset(-10)
//        }
        
        packageTitleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(leftDivider.snp.trailing).offset(10)
            make.trailing.equalTo(rightDivider.snp.leading).offset(-10)
        }
        
//        heartImageView.snp.makeConstraints { make in
//            make.centerY.equalToSuperview()
//            make.trailing.equalToSuperview().offset(-20)
//        }
//        
//        packageBG.snp.makeConstraints { make in
//            make.top.equalTo(contentView.snp.top).offset(10)
//            make.leading.equalToSuperview().offset(20)
//            make.trailing.equalToSuperview().offset(-20)
//            make.bottom.equalTo(contentView.snp.bottom).offset(-10)
//        }
//        
//        packageBGImageView.snp.makeConstraints { make in
//            make.top.equalTo(packageBG)
//            make.leading.equalTo(packageBG)
//            make.trailing.equalTo(packageBG)
//            make.bottom.equalTo(packageBG)
//        }
    }
}

// MARK: - Additional function -

// Configure stackView for each cell
extension SessionTableViewCell {
    
//    func configureStackView(with elements: [UIView]) {
//        // Clear existing arrangedSubviews
//        dynamicStackView.arrangedSubviews.forEach {
//            $0.removeFromSuperview()
//        }
//
//        packageAuthor.setContentHuggingPriority(.defaultHigh, for: .horizontal)
//        packageAuthor.setContentCompressionResistancePriority(.required, for: .horizontal)
//
//        // Add new elements
//        for element in elements {
//            dynamicStackView.addArrangedSubview(element)
//        }
//    }
}


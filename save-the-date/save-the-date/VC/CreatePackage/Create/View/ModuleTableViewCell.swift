//
//  RequestTableViewCell.swift
//  FireBaseGroup2_iOS
//
//  Created by JimmyChao on 2023/10/24.
//

import UIKit
import Foundation
import SnapKit

class ModuleTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = String(describing: ModuleTableViewCell.self)
    // location view
    var deleteButton = UIButton()
    var siteTitle = UILabel()
    var locationView = UIView()
    var bgImageView = UIImageView(image: UIImage(resource: .site04))
    var gradientView = GradientView()
    var arrivedTimeLabel = UILabel()
    
    // transp view
    var transpView = UIView()
    var transpIcon = UIImageView(image: UIImage(systemName: "plus.diamond")!)
    var travelTimeLabel = UILabel()
    
    // Divider
    var leftDivider = UIView()
    var rightDivider = UIView()
    
    var onDelete: ((UITableViewCell) -> Void)?
    var onLocationTapped: ((UITableViewCell) -> Void)?
    var onTranspTapped: ((UITableViewCell) -> Void)?
    
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
        contentView.addSubviews([locationView, transpView])
        locationView.addSubviews([bgImageView, gradientView, deleteButton, siteTitle, arrivedTimeLabel])
        transpView.addSubviews([transpIcon, travelTimeLabel, leftDivider, rightDivider])
        siteTitle.textAlignment = .center
    }
    
    private func setup() {
        
        // Background
        self.backgroundColor = .clear
        
        // Setup transportation view
        transpView.backgroundColor = .clear
        
        // Setup gesture recongnition
        let locationTapGesture = UITapGestureRecognizer(target: self, action: #selector(locationTapped))
        let transportationTapGesture = UITapGestureRecognizer(target: self, action: #selector(transportationTapped))
        locationView.addGestureRecognizer(locationTapGesture)
        transpView.addGestureRecognizer(transportationTapGesture)
        
        // Setup appearance
        locationView.setCornerRadius(20)
            .setBoarderWidth(4)
            .setBoarderColor(.hexToUIColor(hex: "#3F3A3A"))
        
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
        transpIcon.tintColor = .darkGray
        transpIcon.image = UIImage(systemName: "plus.diamond", withConfiguration: config)
        transpIcon.contentMode = .scaleAspectFit
        travelTimeLabel.setFont(UIFont(name: "ChalkboardSE-Regular", size: 18)!).setTextColor(.darkGray)
        
        // Site title appearance
        siteTitle.setFont(UIFont(name: "ChalkboardSE-Regular", size: 18)!)
            .setTextColor(.hexToUIColor(hex: "#3F3A3A"))
        
        // Arrived time label appearance
        arrivedTimeLabel.text = "Should arrived at 8:00 am"
        arrivedTimeLabel.setFont(UIFont(name: "ChalkboardSE-Regular", size: 16)!)
            .setTextColor(.darkGray)
        
        // Divider view appearance
        leftDivider.backgroundColor = .lightGray
        rightDivider.backgroundColor = .lightGray
        
        // BgImageView
        bgImageView.clipsToBounds = true
        bgImageView.setCornerRadius(20)
            .contentMode = .scaleAspectFill
    }
    
    @objc func deleteButtonPressed() {
        // onDelete?(self)
    }
    
    private func setupConstraint() {
        
        transpIcon.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
            make.trailing.equalTo(contentView.snp.centerX).offset(-5)
            make.width.equalTo(35)
            make.height.equalTo(35)
        }
        
        travelTimeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(transpIcon)
            make.leading.equalTo(contentView.snp.centerX).offset(5)
        }
        
        leftDivider.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalTo(transpIcon.snp.leading).offset(-5)
            make.centerY.equalToSuperview()
            make.height.equalTo(1)
        }
        
        rightDivider.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.leading.equalTo(travelTimeLabel.snp.trailing).offset(5)
            make.centerY.equalToSuperview()
            make.height.equalTo(1)
        }
        
        bgImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        gradientView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        siteTitle.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(20)
        }
        
        arrivedTimeLabel.snp.makeConstraints { make in
            make.leading.equalTo(siteTitle.snp.leading)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        locationView.topConstr(to: contentView.topAnchor, 8)
            .leadingConstr(to: contentView.leadingAnchor, 5)
            .trailingConstr(to: contentView.trailingAnchor, -5)
            .centerXConstr(to: contentView.centerXAnchor, 0)
        
        transpView.topConstr(to: locationView.bottomAnchor, 8)
            .leadingConstr(to: contentView.leadingAnchor, 20)
            .trailingConstr(to: contentView.trailingAnchor, -20)
            .bottomConstr(to: contentView.bottomAnchor, 0)
            .heightConstr(50)
    }
}

// MARK: - implement additional functions
extension ModuleTableViewCell {
    
    // On location tapped
    @objc func locationTapped() {
        onLocationTapped?(self)
    }
    
    // On transportation tapped
    @objc func transportationTapped() {
        onTranspTapped?(self)
    }
    
}

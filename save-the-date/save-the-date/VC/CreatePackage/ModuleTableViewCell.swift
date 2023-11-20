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
    var deleteButton = UIButton()
    var numberLabel = UILabel()
    var locationView = UIView()
    
    var transpView = UIView()
    var transpIcon = UIImageView(image: UIImage(systemName: "plus.diamond")!)
    var travelTimeLabel = UILabel()
    
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
        locationView.addSubviews([deleteButton, numberLabel])
        transpView.addSubviews([transpIcon, travelTimeLabel])
        numberLabel.textAlignment = .center
    }
    
    private func setup() {
        deleteButton.setTitle("delete", for: .normal)
        deleteButton.setTitleColor(.red, for: .normal)
        
        // Setup transportation view
        transpView.backgroundColor = .red
        deleteButton.addTarget(self, action: #selector(deleteButtonPressed), for: .touchUpInside)
        
        // Setup gesture recongnition
        let locationTapGesture = UITapGestureRecognizer(target: self, action: #selector(locationTapped))
        let transportationTapGesture = UITapGestureRecognizer(target: self, action: #selector(transportationTapped))
        locationView.addGestureRecognizer(locationTapGesture)
        transpView.addGestureRecognizer(transportationTapGesture)
        
        // Setup appearance
        locationView.setCornerRadius(20)
            .setBoarderWidth(4)
            .setBoarderColor(.hexToUIColor(hex: "#9E9E9E"))

    }
    
    @objc func deleteButtonPressed() {
        onDelete?(self)
    }
    
    private func setupConstraint() {
        
        transpIcon.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.width.equalTo(50)
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
            make.centerX.equalToSuperview()
        }
        
        travelTimeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(transpIcon)
            make.leading.equalTo(transpIcon.snp.trailing).offset(10)
        }
        
        locationView.topConstr(to: contentView.topAnchor, 10)
            .leadingConstr(to: contentView.leadingAnchor, 5)
            .trailingConstr(to: contentView.trailingAnchor, -5)
            .centerXConstr(to: contentView.centerXAnchor, 0)
        
        numberLabel.centerYConstr(to: locationView.centerYAnchor)
            .leadingConstr(to: locationView.leadingAnchor, 10)
        
        deleteButton.centerYConstr(to: locationView.centerYAnchor)
            .heightConstr(50)
            .trailingConstr(to: locationView.trailingAnchor, -10)
            .topConstr(to: locationView.topAnchor, 50)
            .bottomConstr(to: locationView.bottomAnchor, -50)
        
        transpView.topConstr(to: locationView.bottomAnchor, 5)
            .leadingConstr(to: contentView.leadingAnchor, 5)
            .trailingConstr(to: contentView.trailingAnchor, -5)
            .bottomConstr(to: contentView.bottomAnchor, -5)
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

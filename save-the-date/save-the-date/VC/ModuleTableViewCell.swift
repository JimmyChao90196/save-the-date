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
    var transportationView = UIView()
    
    var onDelete: ((UITableViewCell) -> Void)?
    var onLocationTapped: ((UITableViewCell) -> Void)?
    
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
        contentView.addSubviews([locationView, transportationView])
        locationView.addSubviews([deleteButton, numberLabel])
        numberLabel.textAlignment = .center
    }
    
    private func setup() {
        deleteButton.setTitle("delete", for: .normal)
        deleteButton.setTitleColor(.red, for: .normal)
        
        // Setup transportation view
        transportationView.backgroundColor = .red
        deleteButton.addTarget(self, action: #selector(deleteButtonPressed), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(locationTapped))
        locationView.addGestureRecognizer(tapGesture)

    }
    
    @objc func deleteButtonPressed() {
        onDelete?(self)
    }
    
    private func setupConstraint() {
        
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
        
        transportationView.topConstr(to: locationView.bottomAnchor, 5)
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
    
}

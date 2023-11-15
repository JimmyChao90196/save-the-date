//
//  RequestTableViewCell.swift
//  FireBaseGroup2_iOS
//
//  Created by JimmyChao on 2023/10/24.
//

import UIKit
import Foundation

class ModuleTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = String(describing: ModuleTableViewCell.self)
    var deleteButton = UIButton()
    var numberLabel = UILabel()
    var transportationView = UIView()
    var onDelete: ((UITableViewCell) -> Void)?
    
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
        contentView.addSubviews([deleteButton,
                                 numberLabel,
                                 transportationView])
        
        numberLabel.textAlignment = .center
    }
    
    private func setup() {
        deleteButton.setTitle("delete", for: .normal)
        deleteButton.setTitleColor(.red, for: .normal)
        
        // Setup transportation view
        transportationView.backgroundColor = .red
        
        // Remember to disable when perform add target
        deleteButton.addTarget(self, action: #selector(deleteButtonPressed), for: .touchUpInside)
    }
    
    @objc func deleteButtonPressed() {
        onDelete?(self)
    }
    
    private func setupConstraint() {
        
        numberLabel.centerYConstr(to: contentView.centerYAnchor)
            .leadingConstr(to: contentView.leadingAnchor, 10)
        
        deleteButton.centerYConstr(to: contentView.centerYAnchor)
            .heightConstr(50)
            .trailingConstr(to: contentView.trailingAnchor, -10)
            .topConstr(to: contentView.topAnchor, 50)
            .bottomConstr(to: contentView.bottomAnchor, -50)
        
        transportationView.topConstr(to: deleteButton.bottomAnchor, 5)
            .leadingConstr(to: contentView.leadingAnchor, 5)
            .trailingConstr(to: contentView.trailingAnchor, -5)
            .bottomConstr(to: contentView.bottomAnchor, -5)
            .heightConstr(50)
    }
}

//
//  RequestTableViewCell.swift
//  FireBaseGroup2_iOS
//
//  Created by JimmyChao on 2023/10/24.
//

import UIKit
import Foundation


protocol deleteProtocol{
    func onDelete()
}



class NumberTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = String(describing: NumberTableViewCell.self)
    var deleteButton = UIButton()
    var numberLabel = UILabel()
    var onDelete: (() -> Void)?
    var delegate: deleteProtocol?
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addTo()
        setup()
        setupConstraint()
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
        
        // Configure the view for the selected state
    }
    
    private func addTo(){
        contentView.addSubview(deleteButton)
        contentView.addSubview(numberLabel)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.textAlignment = .center
    }
    
    private func setup(){
        deleteButton.setTitle("delete", for: .normal)
        deleteButton.setTitleColor(.red, for: .normal)
        
        //Remember to disable when perform add target
        deleteButton.addTarget(self, action: #selector(deleteButtonPressed), for: .touchUpInside)
    }
    
    
    @objc func deleteButtonPressed(){
        
        //1-1 Notify by using closure
        onDelete?()
        
        //1-3 Notify by using protocol
        delegate?.onDelete()
    }
    
    
    
    private func setupConstraint(){
        NSLayoutConstraint.activate([
            numberLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            numberLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            
            deleteButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            deleteButton.heightAnchor.constraint(equalToConstant: 20),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }
}

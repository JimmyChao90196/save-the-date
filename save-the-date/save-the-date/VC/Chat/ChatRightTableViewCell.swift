//
//  RequestTableViewCell.swift
//  FireBaseGroup2_iOS
//
//  Created by JimmyChao on 2023/10/24.
//

import UIKit
import Foundation

class ChatRightTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = String(describing: ChatRightTableViewCell.self)
    
    var customView = CustomShapeView(
        color: .darkGray,
        frame: CGRect(x: 0, y: 0, width: 40, height: 20))
    
    var messageLabel = UILabel()
    var timeLabel = UILabel()
    var textBG = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addTo()
        setup()
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setup() {
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .right
        customView.backgroundColor = .clear
        
        timeLabel.font = UIFont(name: "PingFangTC-Light", size: 12)
        timeLabel.textColor = .lightGray
        
        textBG.setCornerRadius(12)
            .setbackgroundColor(.darkGray)
    }
    
    private func addTo() {
        contentView.addSubviews([textBG, timeLabel, customView])
        textBG.addSubviews([messageLabel])
        
        messageLabel.textAlignment = .center
        timeLabel.textAlignment = .center
        timeLabel.setTextColor(.gray)
        messageLabel.setTextColor(.white)
    }

    private func setupConstraint() {
        
        customView.centerXConstr(to: textBG.trailingAnchor)
            .topConstr(to: textBG.topAnchor, 0)
            .heightConstr(20)
            .widthConstr(40)
        
        timeLabel.trailingConstr(to: textBG.trailingAnchor, 0)
            .topConstr(to: textBG.bottomAnchor, 2)
            .bottomConstr(to: contentView.bottomAnchor, -2)
        
        NSLayoutConstraint.activate( [
            textBG.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            textBG.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.centerXAnchor, constant: -80),
            textBG.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            
            messageLabel.leadingAnchor.constraint(equalTo: textBG.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: textBG.trailingAnchor, constant: -20),
            messageLabel.topAnchor.constraint(equalTo: textBG.topAnchor, constant: 15),
            messageLabel.bottomAnchor.constraint(equalTo: textBG.bottomAnchor, constant: -15)
        ])
    }
}

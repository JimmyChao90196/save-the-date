//
//  RequestTableViewCell.swift
//  FireBaseGroup2_iOS
//
//  Created by JimmyChao on 2023/10/24.
//

import UIKit
import Foundation
import SnapKit

class ChatLeftTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = String(describing: ChatLeftTableViewCell.self)
    // let chatManager = ChatProvider.shared
    
    var customView = CustomShapeView(
        color: .customDarkGrey,
        frame: CGRect(x: 0, y: 0, width: 40, height: 20))
    
    var messageLabel = UILabel()
    var timeLabel = UILabel()
    var textBG = UIView()
    var profileBG = UIView()
    var profilePic = UIImageView(image: UIImage(systemName: "person.circle"))
    
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
        messageLabel.textAlignment = .left
        customView.backgroundColor = .clear
        
        textBG.setCornerRadius(12)
            .setbackgroundColor(.customDarkGrey)
        timeLabel.font = UIFont(name: "PingFangTC-Light", size: 12)
        timeLabel.textColor = .lightGray
        
        profileBG.clipsToBounds = true
        profilePic.clipsToBounds = true
        profilePic.backgroundColor = .clear
        profilePic.contentMode = .scaleAspectFill
        profileBG.setCornerRadius(20)
            .setbackgroundColor(.hexToUIColor(hex: "#CBCBCB"))
    }
    
    private func addTo() {
        contentView.addSubviews([
            textBG,
            profileBG,
            timeLabel,
            customView])
        
        textBG.addSubviews([messageLabel])
        profileBG.addSubviews([profilePic])
        
        messageLabel.textAlignment = .center
        timeLabel.textAlignment = .center
        timeLabel.setTextColor(.gray)
        messageLabel.setTextColor(.hexToUIColor(hex: "#3F3A3A"))
    }

    private func setupConstraint() {
        
        customView.centerXConstr(to: textBG.leadingAnchor, 0)
            .topConstr(to: textBG.topAnchor, 0)
            .heightConstr(20)
            .widthConstr(40)
        
        profileBG.leadingConstr(to: contentView.leadingAnchor, 10)
            .topConstr(to: textBG.topAnchor, -20)
            .heightConstr(40)
            .widthConstr(40)
        
        profilePic.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        timeLabel.leadingConstr(to: textBG.leadingAnchor, 0)
            .topConstr(to: textBG.bottomAnchor, 2)
            .bottomConstr(to: contentView.bottomAnchor, -2)
        
        NSLayoutConstraint.activate( [
            textBG.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            textBG.leadingAnchor.constraint(equalTo: profileBG.trailingAnchor, constant: 20),
            textBG.trailingAnchor.constraint(lessThanOrEqualTo: contentView.centerXAnchor, constant: 80),
            
            messageLabel.leadingAnchor.constraint(equalTo: textBG.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: textBG.trailingAnchor, constant: -20),
            messageLabel.topAnchor.constraint(equalTo: textBG.topAnchor, constant: 15),
            messageLabel.bottomAnchor.constraint(equalTo: textBG.bottomAnchor, constant: -15)
        ])
    }
}

//
//  ChatVC+Constraints.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/12/26.
//

import Foundation
import UIKit
import IQKeyboardManagerSwift
import FirebaseFirestore
import SnapKit
import Lottie

extension ChatViewController {
    
    func setupConstranit() {
        
        // Set title
        sessionNameTitle.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.snp.topMargin).offset(10)
            make.width.equalTo(200)
            make.height.equalTo(40)
        }
        
        chatBGAnimationView.snp.makeConstraints { make in
            make.edges.equalTo(tableView)
        }
        
        menuHintAnimationView.snp.makeConstraints { make in
            make.edges.equalTo(tableView)
        }
        
        // set top divider
        topDivider.snp.makeConstraints { make in
            make.top.equalTo(view.snp.topMargin)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(2)
        }
        
        footerView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(50)
        }
        
        inputField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalTo(sendButton.snp.leading).offset(-10)
            make.bottom.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(10)
        }
        
        sendButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
            make.width.equalTo(50)
            make.height.equalTo(50)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.topMargin)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(footerView.snp.top)
        }
        
        menuTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }
        
        menuTitleDividerLeft.snp.makeConstraints { make in
            make.trailing.equalTo(menuTitle.snp.leading).offset(-10)
            make.centerY.equalTo(menuTitle.snp.centerY)
            make.height.equalTo(2)
            make.width.equalTo(40)
        }
        
        menuTitleDividerRight.snp.makeConstraints { make in
            make.leading.equalTo(menuTitle.snp.trailing).offset(10)
            make.centerY.equalTo(menuTitle.snp.centerY)
            make.height.equalTo(2)
            make.width.equalTo(40)
        }
        
        sessionsTableView.snp.makeConstraints { make in
            make.top.equalTo(menuTitle.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        foldedView.snp.makeConstraints { make in
            make.top.equalTo(view.snp_topMargin)
            make.width.equalTo(200)
            make.bottom.equalTo(view.snp.bottomMargin)
        }
        
        // Set the initial position off-screen
        foldedViewLeadingConstraint = foldedView.leadingAnchor.constraint(
            equalTo: view.leadingAnchor,
            constant: -200)
        foldedViewLeadingConstraint.isActive = true
    }
}

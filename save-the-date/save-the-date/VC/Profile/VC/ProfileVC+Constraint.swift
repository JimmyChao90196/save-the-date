//
//  ProfileVC+Constraint.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/12/18.
//

import Foundation
import UIKit
import SnapKit

import FirebaseStorage
import FirebaseCore
import FirebaseFirestoreSwift
import ImageIO

extension ProfileViewController {
    
    func setupProfileConstraint() {
        // Description
        descriptionView.snp.makeConstraints { make in
            make.top.equalTo(profileCoverImageView.snp.bottom).offset(10)
            make.bottom.equalTo(selectionView.snp.top).offset(-10)
            make.leading.equalTo(userNameLabel.snp.trailing).offset(40)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        descriptionContent.snp.makeConstraints { make in
            make.centerY.equalTo(descriptionView.snp.centerY)
            make.leading.equalTo(descriptionView.snp.leading).offset(15)
            make.trailing.equalTo(descriptionView.snp.trailing).offset(-15)
        }
        
        userNameLabel.snp.makeConstraints { make in
            make.top.equalTo(profilePicture.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(20)
        }
        
        profileCoverImageView.snp.makeConstraints { make in
            make.top.equalTo(view.snp_topMargin)
            make.height.equalTo(190)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        profilePicture.snp.makeConstraints { make in
            make.centerY.equalTo(profileCoverImageView.snp.bottom)
            make.leading.equalToSuperview().offset(25)
            make.height.equalTo(70)
            make.width.equalTo(70)
        }
        
        leftDivider.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalTo(profilePicture.snp.leading).offset(-10)
            make.top.equalTo(profileCoverImageView.snp.bottom).offset(-15)
            make.height.equalTo(2.5)
        }
        
        rightDivider.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.leading.equalTo(profilePicture.snp.trailing).offset(10)
            make.top.equalTo(profileCoverImageView.snp.bottom).offset(-15)
            make.height.equalTo(2.5)
        }
        
        selectionDivider.snp.makeConstraints { make in
            make.top.equalTo(selectionView.snp.bottom).offset(10)
            make.height.equalTo(2.0)
            make.leading.equalToSuperview().offset(50)
            make.trailing.equalToSuperview().offset(-50)
        }
        
        selectionView.snp.makeConstraints { make in
            make.top.equalTo(profilePicture.snp.bottom).offset(50)
            make.height.equalTo(50)
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(selectionDivider.snp.bottom).offset(7.5)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.bottom.equalTo(view.snp_bottomMargin)
        }
    }
}

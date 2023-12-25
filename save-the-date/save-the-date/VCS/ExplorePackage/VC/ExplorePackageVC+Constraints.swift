//
//  ExplorePackageVC+Constraints.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/12/26.
//

import Foundation
import UIKit

import SnapKit
import CoreLocation

import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseCore
import Lottie

import QuartzCore

extension ExplorePackageViewController {
    func setupNewConstraints() {
        
        animateBGView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.topMargin)
            make.bottom.equalTo(view.snp.bottomMargin)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        // Setup stack view
        dynamicStackView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.topMargin)
            make.leading.equalToSuperview().offset(15)
            make.height.equalTo(50)
        }
        
        clearButton.snp.makeConstraints { make in
            make.top.equalTo(view.snp.topMargin)
            make.centerY.equalTo(dynamicStackView.snp.centerY)
            make.leading.equalTo(dynamicStackView.snp.trailing).offset(5)
            make.trailing.equalToSuperview().offset(-10)
            make.width.equalTo(60)
        }
        
        // Tag guide
        tagGuide.snp.makeConstraints { make in
            make.centerY.equalTo(dynamicStackView.snp.centerY)
            make.leading.equalToSuperview().offset(20)
        }
        
        // Set up scroll view
        recommandedScrollView.snp.makeConstraints { make in
            make.top.equalTo(dynamicStackView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(100)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(recommandedScrollView.snp.bottom)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.bottom.equalTo(view.snp_bottomMargin)
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
        
        chooseCityLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
        }
        
        cityPicker.snp.makeConstraints { make in
            make.top.equalTo(chooseCityLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(150)
        }
        
        chooseDistrictLabel.snp.makeConstraints { make in
            make.top.equalTo(cityPicker.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
        }
        
        districtPicker.snp.makeConstraints { make in
            make.top.equalTo(chooseDistrictLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(150)
        }
        
        applyButton.snp.makeConstraints { make in
            make.top.equalTo(districtPicker.snp.bottom).offset(25)
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(30)
        }
        
        labelLeftDividerA.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalTo(chooseCityLabel.snp.leading).offset(-10)
            make.height.equalTo(2)
            make.centerY.equalTo(chooseCityLabel.snp.centerY)
        }
        
        labelRightDividerA.snp.makeConstraints { make in
            make.leading.equalTo(chooseCityLabel.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(2)
            make.centerY.equalTo(chooseCityLabel.snp.centerY)
        }
        
        labelLeftDividerB.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalTo(chooseDistrictLabel.snp.leading).offset(-10)
            make.height.equalTo(2)
            make.centerY.equalTo(chooseDistrictLabel.snp.centerY)
        }
        
        labelRightDividerB.snp.makeConstraints { make in
            make.leading.equalTo(chooseDistrictLabel.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(2)
            make.centerY.equalTo(chooseDistrictLabel.snp.centerY)
        }
        
        bannerTopDivider.snp.makeConstraints { make in
            make.top.equalTo(view.snp.topMargin)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(3)
        }
        
        bannerTopDividerB.snp.makeConstraints { make in
            make.top.equalTo(dynamicStackView.snp.bottomMargin)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(3)
        }
        
        bannerBottomDivider.snp.makeConstraints { make in
            make.top.equalTo(recommandedScrollView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(3)
        }
    }
}

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

// MARK: - Data Source method -
extension ExplorePackageViewController {
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
            fetchedPackages.count
        }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ExploreTableViewCell.reuseIdentifier,
                for: indexPath) as? ExploreTableViewCell else { return UITableViewCell() }
            
            let likedByArray = fetchedPackages[indexPath.row].info.likedBy
            let isInFavorite = likedByArray.contains { uid in
                uid == userManager.currentUser.uid
            }
            
            // Handle isLike logic
            cell.isLike = isInFavorite
            
            switch isInFavorite {
            case true: cell.heartImageView.image = UIImage(
                systemName: "heart.fill")
                
            case false: cell.heartImageView.image = UIImage(
                systemName: "heart")
            }
            
            let authorNameArray = fetchedPackages[indexPath.row].info.author
            let authorName = authorNameArray.joined(separator: " ")
            let authorPhotoURL = fetchedPackages[indexPath.row].photoURL
            
            let tags = viewModel.createTagsView(
                for: indexPath,
                packages: fetchedPackages)
            
            cell.configureStackView(with: tags)
            cell.packageAuthor.text = " by \(authorName) "
            cell.packageTitleLabel.text = fetchedPackages[indexPath.row].info.title
            
            if fetchedProfileImagesDic == [:] {
                cell.authorPicture.image = UIImage(systemName: "person.circle")
            } else {
                cell.authorPicture.image = fetchedProfileImagesDic[authorPhotoURL]
            }
            cell.authorPicture.tintColor = .customUltraGrey
            cell.onLike = self.onLike
            
            return cell
        }
    
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath) {
            
            let packageDetailVC = PackageDetailViewController()
            packageDetailVC.enterFrom = .explore
            packageDetailVC.currentPackage = fetchedPackages[indexPath.row]
            navigationController?.pushViewController(packageDetailVC, animated: true)
        }
}

// MARK: - Search Delegate method -
extension ExplorePackageViewController: UISearchResultsUpdating, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // Did tap protocol
    func didTapPlace<T>(
        with coordinate: CLLocationCoordinate2D,
        and input: T) {
        }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let text = searchController.searchBar.text else { return }
        self.viewModel.fetchedSearchedPackages(by: text)
    }
    
    // MARK: - UIPickerViewDelegate methods -
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(
        _ pickerView: UIPickerView,
        numberOfRowsInComponent component: Int) -> Int {
            
            if pickerView == self.cityPicker {
                return TaiwanCityModel.allCases.count
            } else {
                return currentCity.districts.count
            }
        }
    
    func pickerView(
        _ pickerView: UIPickerView,
        titleForRow row: Int,
        forComponent component: Int) -> String? {
            
            if pickerView == self.cityPicker {
                return TaiwanCityModel.allCases[row].rawValue
            } else {
                return currentCity.districts[row]
            }
        }
    
    func pickerView(
        _ pickerView: UIPickerView,
        didSelectRow row: Int,
        inComponent component: Int) {
            
            if pickerView == self.cityPicker {
                currentCity = TaiwanCityModel.allCases[row]
                self.inputTags[0] = self.currentCity.rawValue
                self.districtPicker.reloadAllComponents()
                self.inputTags[1] = self.currentCity.districts[0]
                
            } else {
                currentDistrict = currentCity.districts[row]
                self.inputTags[1] = currentDistrict
            }
            
            print(self.inputTags)
            let tags = viewModel.createTagsView(inputTags: inputTags)
            DispatchQueue.main.async {
                self.configureStackView(with: tags)
            }
            
            self.tagGuide.isHidden = true
            self.clearButton.isHidden = false
            
            viewModel.fetchedSearchedPackages(by: self.inputTags)
        }
}

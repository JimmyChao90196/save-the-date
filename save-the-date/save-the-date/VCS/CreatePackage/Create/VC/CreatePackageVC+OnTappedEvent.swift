//
//  CreatePackageVC+OnTappedEvent.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/12/26.
//

import Foundation
import UIKit
import SwiftUI

import SnapKit
import CoreLocation

import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseCore

import GoogleMaps
import GooglePlaces

extension PackageBaseViewController {
    
    // MARK: - Setup onEvents -
    func setupOnComfirm() {
        
        onLocationComfirmMU = { [weak self] location, _, time, action in
            
            guard let self = self else { return }
            self.currentPackage.weatherModules.sunny = self.sunnyModules
            self.currentPackage.weatherModules.rainy = self.rainyModules
            
            viewModel.locationChanged(
                weatherState: weatherState,
                location: location,
                action: action,
                oldPackage: self.currentPackage) { newPackage, module, rawIndex in
                    self.currentPackage = newPackage
                    self.sunnyModules = newPackage.weatherModules.sunny
                    self.rainyModules = newPackage.weatherModules.rainy
                    
                    if module == nil {
                        self.afterEditComfirmed?(rawIndex ?? 0, time)
                    } else {
                        self.afterAppendComfirmed?(module ?? PackageModule())
                    }
                }
        }
        
        onLocationComfirm = { [weak self] location, action in
            
            guard let self = self else { return }
            self.currentPackage.weatherModules.sunny = self.sunnyModules
            self.currentPackage.weatherModules.rainy = self.rainyModules
            
            viewModel.locationChanged(
                weatherState: weatherState,
                location: location,
                action: action,
                oldPackage: self.currentPackage) { newPackage, _, _ in
                    self.currentPackage = newPackage
                    self.sunnyModules = newPackage.weatherModules.sunny
                    self.rainyModules = newPackage.weatherModules.rainy
                }
        }
        
        onTranspComfirm = { [weak self] transp, action, time in
            
            // Show loading
            LKProgressHUD.show()
            
            // Dictate action
            switch action {
                
            case .add:
                print("this shouldn't be triggered")
                
            case .edit( let targetIndex ):
                
                guard let self else { return }
                self.currentPackage.weatherModules.sunny = self.sunnyModules
                self.currentPackage.weatherModules.rainy = self.rainyModules
                
                var sourceRawIndex = 0
                var coords = [CLLocationCoordinate2D]()
                
                viewModel.transpChanged(
                    weatherState: weatherState,
                    targetIndex: targetIndex,
                    tableView: self.tableView,
                    oldPackage: self.currentPackage) { sourceIndex, newCoords in
                        sourceRawIndex = sourceIndex
                        coords = newCoords
                    }
                
                viewModel.fetchTravelTime(
                    with: transp,
                    and: sourceRawIndex,
                    by: coords,
                    weatherState: weatherState,
                    oldPackage: self.currentPackage) { sourceRawIndex in
                        if self.isMultiUser {
                            self.afterEditComfirmed?(sourceRawIndex, time)
                        }
                    }
            }
        }
    }
    
    func setupOnTapped() {
        
        onAddModulePressed = { section in
            print("orig: \(section)")
            
            let exploreVC = ExploreSiteViewController()
            
            if self.isMultiUser {
                exploreVC.actionKind = .add(section)
                exploreVC.onLocationComfirmMU = self.onLocationComfirmMU
            } else {
                exploreVC.onLocationComfirm = self.onLocationComfirm
            }
            
            exploreVC.actionKind = .add(section)
            exploreVC.onLocationComfirmWithAddress = self.onLocationComfirmWithAddress
            self.navigationController?.pushViewController(exploreVC, animated: true)
        }
        
        onTranspTapped = { [weak self] cell in
            guard let indexPath = self?.tableView.indexPath(for: cell),
                  let self = self else { return }
            self.currentPackage.weatherModules.sunny = self.sunnyModules
            self.currentPackage.weatherModules.rainy = self.rainyModules
            
            // Show loading
            LKProgressHUD.show()
            
            var time = 0.0
            
            // Find time first
            time = viewModel.extractTime(
                weatherState: weatherState,
                indexPath: indexPath,
                oldPackage: self.currentPackage)
            
            viewModel.handleTanspTapped(
                docPath: self.documentPath,
                userId: userID,
                userName: userName,
                time: time,
                when: weatherState) { newPackage, newTime in
                    self.currentPackage = newPackage ?? self.currentPackage
                    self.sunnyModules = self.currentPackage.weatherModules.sunny
                    self.rainyModules = self.currentPackage.weatherModules.rainy
                    
                    // Dismiss loading
                    LKProgressHUD.dismiss()
                    
                    // Jump to transpVC
                    let transpVC = TranspViewController()
                    transpVC.onTranspComfirm = self.onTranspComfirm
                    transpVC.timeStamp = self.isMultiUser ? newTime : time
                    transpVC.actionKind = .edit(indexPath)
                    self.navigationController?.pushViewController(transpVC, animated: true)
                }
        }
        
        onLocationTapped = { [weak self] cell in
            
            guard let indexPath = self?.tableView.indexPath(for: cell),
                  let self = self else { return }
            self.currentPackage.weatherModules.sunny = self.sunnyModules
            self.currentPackage.weatherModules.rainy = self.rainyModules
            
            // Show loading
            LKProgressHUD.show()
            
            let time = viewModel.extractTime(
                weatherState: weatherState,
                indexPath: indexPath,
                oldPackage: self.currentPackage)
            
            viewModel.handleLocationTapped(
                docPath: self.documentPath,
                userId: userID,
                userName: userName,
                time: time,
                when: weatherState) { newPackage, newTime, newId in
                    
                    LKProgressHUD.dismiss()
                    
                    self.currentPackage = newPackage ?? self.currentPackage
                    self.sunnyModules = self.currentPackage.weatherModules.sunny
                    self.rainyModules = self.currentPackage.weatherModules.rainy
                    
                    // Go to explore
                    DispatchQueue.main.async {
                        let exploreVC = ExploreSiteViewController()
                        exploreVC.onLocationComfirmMU = self.onLocationComfirmMU
                        exploreVC.onLocationComfirmWithAddress = self.onLocationComfirmWithAddress
                        exploreVC.actionKind = .edit(indexPath)
                        exploreVC.id = newId ?? ""
                        exploreVC.time = newTime ?? TimeInterval()
                        self.navigationController?.pushViewController(exploreVC, animated: true)
                    }
                }
        }
    }
    
    // MARK: - Additional method -
    func changeBGImage() {
        self.bgImageView.contentMode = .scaleAspectFill
        self.bgView.backgroundColor = .hexToUIColor(hex: "#E5E5E5")
        self.tableView.contentMode = .scaleAspectFit
        
        switch self.weatherState {
        case .sunny:
            if self.sunnyModules.isEmpty {
                self.bgImageView.image = UIImage(resource: .createBG02)
                
            } else {
                self.bgImageView.image = UIImage(resource: .createBG03)
            }
        case .rainy:
            if self.rainyModules.isEmpty {
                self.bgImageView.image = UIImage(resource: .createBG02)
                
            } else {
                self.bgImageView.image = UIImage(resource: .createBG03)
            }
        }
    }
    // Logic to swap module
    func movePackage(from source: IndexPath, to destination: IndexPath) {
        
        currentPackage.weatherModules.sunny = sunnyModules
        currentPackage.weatherModules.rainy = rainyModules
        
        viewModel.swapModule(
            docPath: documentPath,
            currentPackage: self.currentPackage,
            source: source,
            dest: destination,
            weatherState: weatherState)
    }
    // Interval formatter
    func formatTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = Int(interval) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)hr \(minutes)min"
        } else if minutes > 0 {
            return "\(minutes)min"
        } else {
            return "0 min"
        }
    }
    
    // Segment control changed
    @objc func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            print("It's sunny")
            weatherState = .sunny
            
        case 1:
            weatherState = .rainy
            print("It's rainy")
        default:
            break
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    // Show route button pressed
    @objc func showRouteButtonPressed() {
        // Go to routeVC
        
        let locations = weatherState == .sunny ?
        sunnyModules.map { $0.location}: rainyModules.map { $0.location }
        
        let coords = locations.map {
            let coord = CLLocationCoordinate2D(
                latitude: $0.coordinate["lat"] ?? 0.0,
                longitude: $0.coordinate["lng"] ?? 0.0)
            return coord }
        
        let routeVC = RouteViewController()
        routeVC.coords = coords
        self.navigationController?.pushViewController(routeVC, animated: true)
    }
}

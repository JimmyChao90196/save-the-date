//
//  CreateVM+OnConfirmed.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/12/24.
//

import Foundation
import UIKit
import GoogleMaps
import GooglePlaces

extension CreateViewModel {
    
    // MARK: - Append -
    func locationAdd(
        weatherState: WeatherState,
        location: Location,
        section: Int,
        currentPackage: Package,
        completion: (PackageModule) -> Void?
    ) {
            
        let module = PackageModule(
            location: location,
            transportation: Transportation(
                transpIcon: "plus.viewfinder",
                travelTime: 0.0),
            day: section)
        
        switch weatherState {
            
        case .sunny:
            var copyPackage = currentPackage
            self.sunnyModules.value.append(module)
            copyPackage.weatherModules.sunny = self.sunnyModules.value
            self.currentPackage.value = copyPackage
            
        case .rainy:
            var copyPackage = currentPackage
            self.rainyModules.value.append(module)
            copyPackage.weatherModules.rainy = self.rainyModules.value
            self.currentPackage.value = copyPackage
        }
        
        fetchPhotosHelperFunction(when: weatherState, with: self.currentPackage.value)
        completion(module)
    }
    
    func locationEdit(
        weatherState: WeatherState,
        currentPackage: Package,
        location: Location,
        id: String,
        time: TimeInterval,
        completion: (Int) -> Void?
    ) {
        
        var modules = weatherState == .sunny ?
        currentPackage.weatherModules.sunny:
        currentPackage.weatherModules.rainy
        
        if let rawIndex = modules.firstIndex(where: {
            if $0.lockInfo.userId == id && $0.lockInfo.timestamp == time {
                return true
            } else { return false }
        }) {
            
            modules[rawIndex].location = location
            
            switch weatherState {
            case .sunny:
                self.sunnyModules.value = modules
                self.currentPackage.value.weatherModules.sunny =
                self.sunnyModules.value
            case .rainy:
                self.rainyModules.value = modules
                self.currentPackage.value.weatherModules.rainy =
                self.rainyModules.value
            }
            
            fetchPhotosHelperFunction(when: weatherState, with: self.currentPackage.value)
            completion(rawIndex)
        }
    }
}

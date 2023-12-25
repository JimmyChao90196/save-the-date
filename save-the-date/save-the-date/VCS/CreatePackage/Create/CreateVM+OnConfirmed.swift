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
    func locationAddMU(
        weatherState: WeatherState,
        location: Location,
        section: Int,
        currentPackage: Package,
        completion: ((PackageModule) -> Void)?
    ) {
        
        let module = PackageModule(
            location: location,
            transportation: Transportation(
                transpIcon: "plus.viewfinder",
                travelTime: 0.0),
            day: section)
        
        var copyCurrentPackage = currentPackage
        var sunnyModules = currentPackage.weatherModules.sunny
        var rainyModules = currentPackage.weatherModules.rainy
        
        if weatherState == .sunny {
            sunnyModules.append(module)
            
        } else {
            rainyModules.append(module)
        }
        
        copyCurrentPackage.weatherModules.sunny = sunnyModules
        copyCurrentPackage.weatherModules.rainy = rainyModules
        
        self.currentPackage.value = copyCurrentPackage
        self.sunnyModules.value = sunnyModules
        self.rainyModules.value = rainyModules
        
        fetchPhotosHelperFunction(
            when: weatherState,
            with: copyCurrentPackage)
        
        completion?(module)
    }
    
    func locationEditMU(
        weatherState: WeatherState,
        currentPackage: Package,
        location: Location,
        id: String,
        time: TimeInterval,
        completion: ((Int) -> Void)?
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
            completion?(rawIndex)
        }
    }
    
    // MARK: - Location changed locally -
    func locationChangeLocal(
        weatherState: WeatherState,
        location: Location,
        action: ActionKind,
        oldPackage: Package,
        completion: ((Package, PackageModule?, Int?) -> Void)? ) {
            
            switch action {
            case .add(let section):
                
                locationAddLocal(
                    weatherState: weatherState,
                    location: location,
                    section: section,
                    oldPackage: oldPackage) { newPackage, module, rawIndex in
                        completion?(newPackage, module, rawIndex)
                    }
                
            case .edit(let targetIndex):
                
                locationEditLocal(
                    weatherState: weatherState,
                    location: location,
                    targetIndex: targetIndex,
                    oldPackage: oldPackage) { newPackage, module, rawIndex in
                        completion?(newPackage, module, rawIndex)
                    }
            }
        }
    
    func locationAddLocal(
        weatherState: WeatherState,
        location: Location,
        section: Int,
        oldPackage: Package,
        completion: ((Package, PackageModule?, Int?) -> Void)? ) {
            let module = PackageModule(
                location: location,
                transportation: Transportation(
                    transpIcon: "plus.viewfinder",
                    travelTime: 0.0),
                day: section)
            
            var copyPackage = oldPackage
            var sunnyModules = oldPackage.weatherModules.sunny
            var rainyModules = oldPackage.weatherModules.rainy
            
            if weatherState == .sunny {
                sunnyModules.append(module)
                
            } else {
                rainyModules.append(module)
            }
            
            copyPackage.weatherModules.sunny = sunnyModules
            copyPackage.weatherModules.rainy = rainyModules
            completion?(copyPackage, module, nil)
            fetchPhotosHelperFunction(when: weatherState, with: copyPackage)
        }
    
    func locationEditLocal(
        weatherState: WeatherState,
        location: Location,
        targetIndex: IndexPath,
        oldPackage: Package,
        completion: ((Package, PackageModule?, Int?) -> Void)? ) {
            
            var copyPackage = oldPackage
            var sunnyModules = oldPackage.weatherModules.sunny
            var rainyModules = oldPackage.weatherModules.rainy
            var rawIndex = 0
            
            if weatherState == .sunny {
                if let index = findModuleIndex(
                    modules: sunnyModules,
                    from: targetIndex) {
                    sunnyModules[index].location = location
                    rawIndex = index
                }
                
            } else {
                if let index = findModuleIndex(
                    modules: rainyModules,
                    from: targetIndex) {
                    rainyModules[index].location = location
                    rawIndex = index
                }
            }
            
            copyPackage.weatherModules.sunny = sunnyModules
            copyPackage.weatherModules.rainy = rainyModules
            completion?(copyPackage, nil, rawIndex)
            fetchPhotosHelperFunction(when: weatherState, with: copyPackage)
        }
   
}

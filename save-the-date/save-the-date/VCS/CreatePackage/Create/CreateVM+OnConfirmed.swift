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
    
    func locationEdit(
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
    
    func locationEditLocal(
        weatherState: WeatherState,
        targetIndex: IndexPath,
        location: Location,
        currentPackage: Package) {
            
            var modules = weatherState == .sunny ?
            currentPackage.weatherModules.sunny:
            currentPackage.weatherModules.rainy
            
            let index = findModuleIndex(modules: modules, from: targetIndex)
            
            switch weatherState {
            case .sunny:
                modules[index ?? 0].location = location
                self.sunnyModules.value = modules
                self.currentPackage.value.weatherModules.sunny =
                self.sunnyModules.value
                
            case .rainy:
                modules[index ?? 0].location = location
                self.rainyModules.value = modules
                self.currentPackage.value.weatherModules.rainy =
                self.rainyModules.value
            }
            
            fetchPhotosHelperFunction(
                when: weatherState,
                with: self.currentPackage.value)
        }
}

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
    
    // MARK: - Transp changed -
    func transpChanged(
        weatherState: WeatherState,
        targetIndex: IndexPath,
        tableView: UITableView,
        oldPackage: Package,
        completion: (Int, [CLLocationCoordinate2D]) -> Void?
    ) {
        
        var copyPackage = oldPackage
        var sunnyModules = oldPackage.weatherModules.sunny
        var rainyModules = oldPackage.weatherModules.rainy
        
        let modules = weatherState == .sunny ? sunnyModules: rainyModules
        
        let rawDestIndexPath = findNextIndexPath(
            currentIndex: targetIndex,
            in: tableView)
        
        let sourceRawIndex = findModuleIndex(
            modules: modules,
            from: targetIndex) ?? 0
        
        let destRawIndex = findModuleIndex(
            modules: modules,
            from: rawDestIndexPath ?? IndexPath()) ?? 0
        
        let sourceCoordDic = modules[sourceRawIndex].location.coordinate
        let destCoordDic = modules[destRawIndex].location.coordinate
        
        // Fetch travel time
        let sourceCoord = CLLocationCoordinate2D(
            latitude: sourceCoordDic["lat"] ?? 0,
            longitude: sourceCoordDic["lng"] ?? 0)
        
        let destCoord = CLLocationCoordinate2D(
            latitude: destCoordDic["lat"] ?? 0,
            longitude: destCoordDic["lng"] ?? 0)
        
        // Breaking system
        if sourceCoord.latitude == 0 || destCoord.latitude == 0 {
            LKProgressHUD.dismiss()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                LKProgressHUD.showFailure(text: "Not enough data provided")
            }
            completion(sourceRawIndex, [sourceCoord, destCoord])
            return
        }
        
        completion(sourceRawIndex, [sourceCoord, destCoord])
    }
    
    // MARK: - Location changed -
    func locationChanged(
        weatherState: WeatherState,
        location: Location,
        action: ActionKind,
        oldPackage: Package,
        completion: ((Package, PackageModule?, Int?) -> Void)? ) {
            
            switch action {
            case .add(let section):
                
                locationAdd(
                    weatherState: weatherState,
                    location: location,
                    section: section,
                    oldPackage: oldPackage) { newPackage, module, rawIndex in
                        completion?(newPackage, module, rawIndex)
                    }
                
            case .edit(let targetIndex):
                
                locationEdit(
                    weatherState: weatherState,
                    location: location,
                    targetIndex: targetIndex,
                    oldPackage: oldPackage) { newPackage, module, rawIndex in
                        completion?(newPackage, module, rawIndex)
                    }
            }
        }
    
    func locationAdd(
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
    
    func locationEdit(
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

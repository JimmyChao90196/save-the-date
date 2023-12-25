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
import MapKit
import CoreLocation

extension CreateViewModel {
    
    func extractTime(
        weatherState: WeatherState,
        indexPath: IndexPath,
        oldPackage: Package) -> TimeInterval {
        
            var time = TimeInterval()
            let sunnyModules = oldPackage.weatherModules.sunny
            let rainyModules = oldPackage.weatherModules.rainy
            
            if weatherState == .sunny {
                let rawIndex = findModuleIndex(modules: sunnyModules, from: indexPath) ?? 0
                time = sunnyModules[rawIndex].lockInfo.timestamp
            } else {
                let rawIndex = findModuleIndex(modules: rainyModules, from: indexPath) ?? 0
                time = rainyModules[rawIndex].lockInfo.timestamp
            }
            
            return time
    }
    
    func handleLocationTapped(
        docPath: String,
        userId: String,
        userName: String,
        time: TimeInterval,
        when: WeatherState,
        completion: ((Package?, TimeInterval?, String?) -> Void)?
    ) {
        
        if docPath == "" {
            completion?(nil, nil, nil)
            
        } else {
            
            self.firestoreManager.lockModuleWithTrans(
                docPath: docPath,
                userId: userId,
                userName: userName,
                time: time,
                when: when) { newPackage, newIndex, isLate in
                    
                    let sunnyModules = newPackage.weatherModules.sunny
                    let rainyModules = newPackage.weatherModules.rainy
                    var newTime = TimeInterval()
                    var id = ""
                    
                    if when == .sunny {
                        id = sunnyModules[newIndex].lockInfo.userId
                        newTime = sunnyModules[newIndex].lockInfo.timestamp
                    } else {
                        id = rainyModules[newIndex].lockInfo.userId
                        newTime = rainyModules[newIndex].lockInfo.timestamp
                    }
                    
                    if isLate {
                        LKProgressHUD.dismiss()
                        return
                    } else {
                        completion?(newPackage, newTime, id)
                    }
                }
        }
    }
    
    func handleTanspTapped(
        docPath: String,
        userId: String,
        userName: String,
        time: TimeInterval,
        when: WeatherState,
        completion: ((Package?, TimeInterval) -> Void)?
    ) {
        
        if docPath == "" {
            completion?(nil, time)
        } else {
            
            self.firestoreManager.lockModuleWithTrans(
                docPath: docPath,
                userId: userId,
                userName: userName,
                time: time,
                when: when) { newPackage, newIndex, isLate in
                    
                    let sunnyModules = newPackage.weatherModules.sunny
                    let rainyModules = newPackage.weatherModules.rainy
                    var newTime = TimeInterval()
                    
                    if when == .sunny {
                        newTime = sunnyModules[newIndex].lockInfo.timestamp
                    } else {
                        newTime = rainyModules[newIndex].lockInfo.timestamp
                    }
                    
                    if isLate {
                        return
                    } else {
                        completion?(newPackage, newTime)
                    }
                }
        }
    }
    
    // MARK: - Transp changed -
    func fetchTravelTime(
        with transp: TranspManager,
        and sourceRawIndex: Int,
        by coords: [CLLocationCoordinate2D],
        weatherState: WeatherState,
        oldPackage: Package,
        completion: ((Int) -> Void)?
    ) {
        let sourceCoord = coords[0]
        let destCoord = coords[1]
        if sourceCoord.latitude == 0 || destCoord.latitude == 0 { LKProgressHUD.dismiss(); return }
        var copyPackage = oldPackage
        var sunnyModules = oldPackage.weatherModules.sunny
        var rainyModules = oldPackage.weatherModules.rainy
        
        self.routeManager.fetchTravelTime(
            with: transp.transpType,
            from: sourceCoord,
            to: destCoord,
            completion: { travelTime in
                
                let transportation = Transportation(
                    transpIcon: transp.transIcon,
                    travelTime: travelTime)
                
                // Replace with new transporation
                if weatherState == .sunny {
                    
                    sunnyModules[sourceRawIndex].transportation = transportation
                    self.sunnyModules.value = sunnyModules
                    copyPackage.weatherModules.sunny = sunnyModules
                    completion?(sourceRawIndex)
                    
                } else {
                    
                    rainyModules[sourceRawIndex].transportation = transportation
                    self.rainyModules.value = rainyModules
                    copyPackage.weatherModules.rainy = rainyModules
                    completion?(sourceRawIndex)
                }
                
                // Dissmiss loading
                LKProgressHUD.dismiss()

            })
    }
    
    func transpChanged(
        weatherState: WeatherState,
        targetIndex: IndexPath,
        tableView: UITableView,
        oldPackage: Package,
        completion: (Int, [CLLocationCoordinate2D]) -> Void?
    ) {
        
        let sunnyModules = oldPackage.weatherModules.sunny
        let rainyModules = oldPackage.weatherModules.rainy
        
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

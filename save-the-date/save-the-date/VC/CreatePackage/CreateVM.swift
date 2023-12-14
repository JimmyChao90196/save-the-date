//
//  CreateVM.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/30.
//

import Foundation
import GoogleMaps
import GooglePlaces

class CreateViewModel {
    
    let regionTags = Box<[String]>([])
    
    // Check if the package is empty
    func shouldPublish(
        sunnyModule: [PackageModule],
        rainyModule: [PackageModule]) -> Bool {
            
        if sunnyModule == [] && rainyModule == [] {
            return false
        } else {
            return true
        }
    }
    
    // ParseAddress
    func parseAddress(
        from addressComponents: [GMSAddressComponent]?,
        currentTags: [String]
    ) {
        var city: String?
        var district: String?
        var country: String?
        
        guard let addressComponents else { return }

        for component in addressComponents {
            // Check if the component is a city
            if component.types.contains("administrative_area_level_1") {
                city = component.name
            }
            // Check if the component is a district
            else if component.types.contains("administrative_area_level_2") {
                district = component.name
                
            } else if component.types.contains("country") {
                // This is the country
                country = component.name
                
            }
        }
        
        // Append to region
        var tagSet = Set(currentTags)
        
        if let city, let district, let country {
            
            tagSet.insert(city)
            tagSet.insert(district)
            tagSet.insert(country)
        }
        
        regionTags.value = Array(tagSet)
    }
}

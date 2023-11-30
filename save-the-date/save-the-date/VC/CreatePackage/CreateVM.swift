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
    
    // ParseAddress
    func parseAddress(from addressComponents: [GMSAddressComponent]?) {
        var city: String?
        var district: String?
        
        guard let addressComponents else { return }

        for component in addressComponents {
            // Check if the component is a city
            if component.types.contains("administrative_area_level_1") {
                city = component.name
            }
            // Check if the component is a district
            else if component.types.contains("administrative_area_level_2") {
                district = component.name
            }
        }
        
        // Append to region
        var tagSet = Set(regionTags.value)
        
        if let city, let district {
            
            tagSet.insert(city)
            tagSet.insert(district)
        }
        
        regionTags.value = Array(tagSet)
    }
}

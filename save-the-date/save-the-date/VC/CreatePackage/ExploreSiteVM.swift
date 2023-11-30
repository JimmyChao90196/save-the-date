//
//  ExploreSiteVM.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/30.
//

import Foundation
import UIKit
import GoogleMaps
import GooglePlaces

class ExploreSiteViewModel {
    
    let googlePlacesManager = GooglePlacesManager.shared
    
    let location = Box(Location(address: "none", shortName: "none", identifier: "none"))
    let placeImage = Box(UIImage())
    let regionTags = Box<[String]>([])
    
    // Fetch placeInfo
    func fetchPlaceInfo(identifier id: String) {
        Task {
            
            let place = try await self.googlePlacesManager.resolveLocation(for: id)
            
            guard let photoData = place.photos?.first else { return }
            
            placeImage.value = try await self.googlePlacesManager.resolvePhoto(
                from: photoData )
        }
    }
    
    // ParseAddress
    func parseAddress(from addressComponents: [GMSAddressComponent]) {
        var city: String?
        var district: String?

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

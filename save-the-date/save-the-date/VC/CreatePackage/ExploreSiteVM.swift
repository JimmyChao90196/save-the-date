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
}

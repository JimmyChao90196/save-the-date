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
    
    let googlePlaceManger = GooglePlacesManager.shared
    
    let regionTags = Box<[String]>([])
    var sunnyPhotos = Box<[String: UIImage]>([:])
    var rainyPhotos = Box<[String: UIImage]>([:])
    
    // Fake rating system.
    func ratingForIndexPath(indexPath: IndexPath, minimumRating: Double = 3.0) -> String {
        // Use the hash value of the index path as a seed substitute
        let seed = indexPath.hashValue
        var rng = SeededGenerator(seed: seed)

        // Ensure minimumRating is within the valid range (0 to 5)
        let clampedMinimumRating = min(max(minimumRating, 0.0), 5.0)

        // Generate a random rating between clampedMinimumRating and 5
        let maxRating = 5
        let rating = max(Double.random(in: 0...5, using: &rng), clampedMinimumRating)
        let fullStarCount = Int(rating)
        let fullStarString = String(repeating: "★", count: fullStarCount)
        let emptyStarCount = maxRating - fullStarCount
        let emptyStarString = String(repeating: "☆", count: emptyStarCount)
        return fullStarString + emptyStarString
    }

    // Custom random number generator using a hash value as a seed
    struct SeededGenerator: RandomNumberGenerator {
        private var state: UInt64

        init(seed: Int) {
            state = UInt64(abs(seed))
        }

        mutating func next() -> UInt64 {
            state = 6364136223846793005 &* state &+ 1
            return state
        }
    }

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
    
    func mapToDictionary(module: [PackageModule]) -> [String: String] {
        
        var dict = [String: String]()
        
        for item in module {
            dict[item.location.identifier] = item.location.photoReference
        }
        
        return dict
    }
        
    func fetchSitePhotos(
        weatherState: WeatherState,
        photoReferences: [String: String]?) {
            
            guard let photoReferences = photoReferences else { return }
            
            googlePlaceManger.fetchPhotos(
                photoReferences: photoReferences) { result in
                    switch result {
                    case .success(let success):
                        switch weatherState {
                        case .sunny:
                            self.sunnyPhotos.value = success
                        case .rainy:
                            self.rainyPhotos.value = success
                        }
                        
                    case .failure(let failure):
                        print("faild fetching photos: \(failure)")
                    }
                }
        }
}

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

    func fetchPlacePhotoReferences(placeID: String) async throws -> [String] {
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "maps.googleapis.com"
        components.path = "/maps/api/place/details/json"
        components.queryItems = [
            URLQueryItem(name: "place_id", value: placeID),
            URLQueryItem(name: "fields", value: "photo"),
            URLQueryItem(name: "key", value: "AIzaSyDKpRUS5pK0qBRxosBaXhazzsyWING1GxY") 
        ]

        guard let url = components.url else {
            throw NSError(domain: "Invalid URL", code: -1, userInfo: nil)
        }

        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let data = data else {
                    continuation.resume(throwing: NSError(domain: "No Data", code: -1, userInfo: nil))
                    return
                }

                do {
                    if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let result = jsonResult["result"] as? [String: Any],
                       let photos = result["photos"] as? [[String: Any]] {
                        let photoReferences = photos.compactMap { $0["photo_reference"] as? String }
                        continuation.resume(returning: photoReferences)
                    } else {
                        continuation.resume(throwing: NSError(domain: "Parsing Error", code: -2, userInfo: nil))
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            }.resume()
        }
    }

}

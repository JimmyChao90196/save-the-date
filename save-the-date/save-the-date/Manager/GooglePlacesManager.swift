//
//  GooglePlacesManager.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/16.
//

import Foundation
import GooglePlaces

enum PlacesError: Error {
    case faildToFind
    case faildToGetCoordinate
}

final class GooglePlacesManager {
    
    static let shared = GooglePlacesManager()
    
    private let client = GMSPlacesClient.shared()
    
    private init() {}
    
    public func findPlaces(
        query: String,
        completion: @escaping (Result<[Place], Error>) -> Void
    ) {
        let filter = GMSAutocompleteFilter()
        client.findAutocompletePredictions(
            fromQuery: query,
            filter: filter,
            sessionToken: nil) { results, error in
                
                // If faild then return
                guard let results, error == nil else {
                    completion(.failure(PlacesError.faildToFind))
                    return
                }
                
                let places: [Place] = results.compactMap {
                    Place(
                        name: $0.attributedFullText.string,
                        shortName: $0.attributedPrimaryText.string,
                        identifier: $0.placeID
                    )
                }
                // If success then return places
                completion(.success(places))
            }
    }
    
    public func resolveLocation(
        for place: Place,
        completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void) {
            
            client.fetchPlace(
                fromPlaceID: place.identifier,
                placeFields: .coordinate,
                sessionToken: nil)
             { googlePlace, error in
                guard let googlePlace, error == nil else {
                    completion(.failure(PlacesError.faildToGetCoordinate))
                    return
                }
                
                let coordinate = CLLocationCoordinate2D(
                    latitude: googlePlace.coordinate.latitude,
                    longitude: googlePlace.coordinate.longitude
                )
                completion(.success(coordinate))
            }
        }
}

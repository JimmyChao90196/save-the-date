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
    
    public func findLocations(
        query: String,
        completion: @escaping (Result<[Location], Error>) -> Void
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
                
                let places: [Location] = results.compactMap {
                    Location(
                        address: $0.attributedFullText.string,
                        shortName: $0.attributedPrimaryText.string,
                        identifier: $0.placeID
                    )
                }
                // If success then return places
                completion(.success(places))
            }
    }
    
    public func resolvePhoto(from photoMetaData: GMSPlacePhotoMetadata) async throws -> UIImage {
        return try await withCheckedThrowingContinuation { continuation in
            
            var copyMetaData = photoMetaData
            
            client.loadPlacePhoto(photoMetaData) { photo, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let photo = photo {
                    continuation.resume(returning: photo)
                } else {
                    continuation.resume(throwing: error!)
                }
            }
        }
    }
    
    public func resolveLocation(for identifier: String) async throws -> GMSPlace {
        return try await withCheckedThrowingContinuation { continuation in
            client.fetchPlace(fromPlaceID: identifier, placeFields: .all, sessionToken: nil) { googlePlace, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let googlePlace = googlePlace {
                    continuation.resume(returning: googlePlace)
                } else {
                    continuation.resume(throwing: error!)
                }
            }
        }
    }

    public func resolveLocation(
        for location: Location,
        completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void) {
            
            client.fetchPlace(
                fromPlaceID: location.identifier,
                placeFields: .coordinate,
                sessionToken: nil) { googlePlace, error in
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
    
    public func resolveLocations(for locations: [Location], completion: @escaping ([CLLocationCoordinate2D]) -> Void) {
        var coords = [CLLocationCoordinate2D]()
        let dispatchGroup = DispatchGroup()

        locations.forEach { location in
            dispatchGroup.enter()

            client.fetchPlace(
                fromPlaceID: location.identifier,
                placeFields: .coordinate,
                sessionToken: nil) { googlePlace, error in
                defer { dispatchGroup.leave() }

                if let googlePlace = googlePlace, error == nil {
                    let coordinate = CLLocationCoordinate2D(
                        latitude: googlePlace.coordinate.latitude,
                        longitude: googlePlace.coordinate.longitude)
                    
                    print(coordinate)
                    coords.append(coordinate)
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(coords) 
        }
    }
}

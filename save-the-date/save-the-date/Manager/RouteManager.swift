//
//  RouteManager.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/17.
//

import Foundation
import GooglePlaces
import GoogleMaps
import CoreLocation
import MapKit

class RouteManager {
    
    static let shared = RouteManager()
    
    func fetchTravelTime(
        with transportation: MKDirectionsTransportType,
        from sourceCoord: CLLocationCoordinate2D,
        to destCoord: CLLocationCoordinate2D,
        completion: @escaping (TimeInterval) -> Void) {
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceCoord)
        let destPlacemark = MKPlacemark(coordinate: destCoord)
        
        let destinationRequest = MKDirections.Request()
        destinationRequest.source = MKMapItem(placemark: sourcePlacemark)
        destinationRequest.destination = MKMapItem(placemark: destPlacemark)
        destinationRequest.transportType = transportation
        destinationRequest.requestsAlternateRoutes = true
        
        let directions = MKDirections(request: destinationRequest)
        directions.calculate { (response, _) in
            guard let response = response else { return }
            
            let route = response.routes[0]
            let travelTime = route.expectedTravelTime
            completion(travelTime)
        }
    }
    
    func fetchRoute(
        from sourceCoord: CLLocationCoordinate2D,
        to destCoord: CLLocationCoordinate2D,
        on mapView: MKMapView) {
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceCoord)
        let destPlacemark = MKPlacemark(coordinate: destCoord)
        
        let destinationRequest = MKDirections.Request()
        destinationRequest.source = MKMapItem(placemark: sourcePlacemark)
        destinationRequest.destination = MKMapItem(placemark: destPlacemark)
        destinationRequest.transportType = .automobile
        destinationRequest.requestsAlternateRoutes = true
        
        let directions = MKDirections(request: destinationRequest)
        directions.calculate { (response, _) in
            guard let response = response else { return }
            
            let route = response.routes[0]
            mapView.addOverlay(route.polyline)
            mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
        }
    }
    
    func drawRoutes(_ coordinates: [CLLocationCoordinate2D], on mapView: MKMapView) {
        
        // Remove previous annotation
        let annotations = mapView.annotations
        mapView.removeAnnotations(annotations)
        
        // Add pin
        coordinates.forEach { coord in
            
            // Add pin
            let pin = MKPointAnnotation()
            pin.coordinate = coord
            mapView.addAnnotation(pin)
            mapView.setRegion(
                MKCoordinateRegion(
                    center: coord,
                    span: MKCoordinateSpan(
                        latitudeDelta: 0.2,
                        longitudeDelta: 0.2)),
                animated: true)
        }
        
        // Draw routes
        for index in 0..<coordinates.count-1 {
            let sourceCoord = coordinates[index]
            let destCoord = coordinates[index + 1]
            
            fetchRoute(from: sourceCoord, to: destCoord, on: mapView)
        }
    }
}

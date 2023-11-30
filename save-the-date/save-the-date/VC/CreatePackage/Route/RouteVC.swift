//
//  RouteVC.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/17.
//

import Foundation
import SnapKit
import UIKit
import MapKit

import CoreLocation
import GooglePlaces
import GoogleMaps

class RouteViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    let mapView = MKMapView()
    var manager = CLLocationManager()
    var routeManager = RouteManager.shared
    var coords = [CLLocationCoordinate2D]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTo()
        setup()
        setConstraint()
    }

    func addTo() {
        view.addSubviews([mapView])
        mapView.delegate = self
    }
    
    func setup() {
        routeManager.drawRoutes(coords, on: mapView)
    }
    
    func setConstraint() {
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}

// MARK: - Delegate method -
extension RouteViewController {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay as? MKPolyline ?? MKPolyline())
        render.strokeColor = .blue
        return render
    }
}

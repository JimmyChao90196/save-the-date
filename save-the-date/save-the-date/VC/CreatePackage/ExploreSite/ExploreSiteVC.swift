//
//  ExploreSiteViewController.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/15.
//

import Foundation
import SnapKit
import UIKit
import MapKit

import CoreLocation
import GooglePlaces
import GoogleMaps

enum ActionKind {
    case edit(IndexPath)
    case add(Int)
}

class ExploreSiteViewController: UIViewController, CLLocationManagerDelegate {
    
    
    var id = ""
    var time = TimeInterval()
    
    var googlePlacesManager = GooglePlacesManager.shared
    var manager = CLLocationManager()
    var updateCount = 0
    
    // Google map
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    var googleMapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var preciseLocationZoomLevel: Float = 15.0
    var approximateLocationZoomLevel: Float = 10.0
    
    // let mapView = MKMapView()
    var placeDetailView = UIView()
    var placeTitle = UILabel()
    
    var selectedLocation = Location(
        name: "None",
        shortName: "None",
        identifier: "None")
    
    var acceptButton = UIButton()
    let searchVC = UISearchController(searchResultsController: ResultViewController())
    var actionKind = ActionKind.add(1)
    
    // On event closure
    var onLocationComfirm: ( (Location, ActionKind) -> Void )?
    var onComfirmWithMultiUser: ( (Location, String, TimeInterval) -> Void )?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeGoogleMap()
        addTo()
        setup()
        setupConstraint()
    }
    
    func setup() {
        view.backgroundColor = .white
        
        // Customize search VC
        searchVC.searchBar.backgroundColor = .secondarySystemGroupedBackground
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
        
        // Customize detail view
        placeTitle.text = "請選擇地點"
        placeTitle.setTextColor(.black)
            .setbackgroundColor(.blue)
        
        placeDetailView.setCornerRadius(20)
            .setbackgroundColor(.white)
            .setBoarderWidth(1)
            .setBoarderColor(.hexToUIColor(hex: "#CCCCCC"))
        
        // Customize button
        acceptButton.setTarget(self, action: #selector(acceptButtonPressed), for: .touchUpInside)
            .setbackgroundColor(.systemPink)
            .setTitle("Comfirm", for: .normal)
    }
    
    func addTo() {
        view.addSubviews([googleMapView])
        googleMapView.addSubviews([placeDetailView])
        placeDetailView.addSubviews([placeTitle, acceptButton])
    }
    
    func setupConstraint() {
        
        googleMapView.snp.makeConstraints { make in
            make.top.equalTo(view.snp_topMargin)
            make.bottom.equalTo(view.snp_bottomMargin)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        placeDetailView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalTo(view.snp_bottomMargin).offset(-5)
            make.height.equalTo(120)
        }
        
        placeTitle.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(20)
            make.height.equalTo(20)
        }
        
        acceptButton.snp.makeConstraints { make in
            make.top.equalTo(placeTitle.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(20)
        }
    }

    // MARK: - Accept button pressed
    @objc func acceptButtonPressed() {
        onComfirmWithMultiUser?(selectedLocation, id, time)
        onLocationComfirm?(selectedLocation, actionKind)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Additional methods -
extension ExploreSiteViewController {
    
    func initializeGoogleMap() {
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        print("License: \(GMSServices.openSourceLicenseInfo())")
        
        let coordinate = CLLocationCoordinate2D(latitude: 25.033964, longitude: 121.5644722)
        
        let options = GMSMapViewOptions()
        
        options.camera = GMSCameraPosition.camera(
            withLatitude: coordinate.latitude,
            longitude: coordinate.longitude,
            zoom: 6.0)
        options.frame = self.view.bounds
        
        googleMapView = GMSMapView(options: options)
        self.view.addSubview(googleMapView)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        let zoomLevel = manager.accuracyAuthorization == .fullAccuracy ?
        preciseLocationZoomLevel : approximateLocationZoomLevel
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        if updateCount < 1 {
            googleMapView.animate(to: camera)
            
            // remove marker
            googleMapView.clear()
            
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude)
            marker.title = "Current"
            marker.snippet = "Current"
            marker.map = googleMapView
            
            // Add 1 for each update
            updateCount += 1
        }
    }
}

// MARK: - Search delegate method -
extension ExploreSiteViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        // Get the query argument
        guard let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              let resultVC = searchController.searchResultsController as? ResultViewController
        else { return }
        
        resultVC.delgate = self
        
        googlePlacesManager.findLocations(query: query) { result in
            switch result {
            case .success(let locations):
                
                DispatchQueue.main.async {
                    resultVC.update(with: locations)
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
}

// MARK: - Result view controller delegate method -

extension ExploreSiteViewController: ResultViewControllerDelegate {
    
    func didTapPlace(with coordinate: CLLocationCoordinate2D, targetPlace: Location) {
        
        self.selectedLocation = targetPlace
        self.selectedLocation.coordinate["lat"] = coordinate.latitude
        self.selectedLocation.coordinate["lng"] = coordinate.longitude
        
        placeTitle.text = selectedLocation.shortName
        
        // Hide keyboard and dismiss search VC
        searchVC.searchBar.resignFirstResponder()
        searchVC.dismiss(animated: true, completion: nil)
        
        // Set zoom level
        let zoomLevel = manager.accuracyAuthorization == .fullAccuracy ?
        preciseLocationZoomLevel : approximateLocationZoomLevel
        let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude,
                                              longitude: coordinate.longitude,
                                              zoom: zoomLevel)
        // Move to target
        googleMapView.animate(to: camera)
        
        // remove marker
        googleMapView.clear()
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude)
        marker.title = targetPlace.shortName
        marker.snippet = targetPlace.name
        marker.map = googleMapView
    }
}

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
    case edit(UITableViewCell)
    case add
}

class ExploreSiteViewController: UIViewController, CLLocationManagerDelegate {
    
    var packageManager = PackageManager.shared
    var googlePlacesManager = GooglePlacesManager.shared
    var manager = CLLocationManager()
    
    let mapView = MKMapView()
    var placeDetailView = UIView()
    var placeTitle = UILabel()
    
    var currentLocation = Location(
        name: "None",
        shortName: "None",
        identifier: "None")
    
    var acceptButton = UIButton()
    let searchVC = UISearchController(searchResultsController: ResultViewController())
    var actionKind = ActionKind.add
    
    // On event closure
    var onLocationComfirm: ( (Location, ActionKind) -> Void )?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTo()
        setup()
        initializeGoogleMap()
        setupConstraint()
    }
    
    func setup() {
        view.backgroundColor = .white
        mapView.frame = view.bounds
        
        // Customize search VC
        searchVC.searchBar.backgroundColor = .secondarySystemGroupedBackground
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
        
        // Customize detail view
        placeTitle.text = "請選擇地點"
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
        // view.addSubviews([mapView])
        // mapView.addSubviews([placeDetailView])
        // placeDetailView.addSubviews([placeTitle, acceptButton])
    }
    
    func setupConstraint() {
//        mapView.snp.makeConstraints { make in
//            make.left.equalToSuperview()
//            make.right.equalToSuperview()
//            make.top.equalTo(view.safeAreaLayoutGuide)
//            make.bottom.equalTo(view.safeAreaLayoutGuide)
//        }
        
//        placeDetailView.snp.makeConstraints { make in
//            make.left.equalToSuperview().offset(10)
//            make.right.equalToSuperview().offset(-10)
//            make.bottom.equalToSuperview().offset(-5)
//            make.height.equalTo(120)
//        }
//        
//        placeTitle.snp.makeConstraints { make in
//            make.centerX.equalToSuperview()
//            make.top.equalToSuperview().offset(20)
//        }
//        
//        acceptButton.snp.makeConstraints { make in
//            make.top.equalTo(placeTitle.snp.bottom).offset(10)
//            make.centerX.equalToSuperview()
//            make.height.equalTo(20)
//        }
    }

    // MARK: - Accept button pressed
    @objc func acceptButtonPressed() {
        
        onLocationComfirm?(currentLocation, actionKind)
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
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        let coordinate = location.coordinate
        
        let options = GMSMapViewOptions()
        
        options.camera = GMSCameraPosition.camera(
            withLatitude: coordinate.latitude,
            longitude: coordinate.longitude,
            zoom: 6.0)
        options.frame = self.view.bounds

        let mapView = GMSMapView(options: options)
        self.view.addSubview(mapView)

        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
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
                print(locations)
                
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
        
        self.currentLocation = targetPlace
        placeTitle.text = currentLocation.shortName
        
        // Hide keyboard and dismiss search VC
        searchVC.searchBar.resignFirstResponder()
        searchVC.dismiss(animated: true, completion: nil)
        
        // Remove all map pin
        let annotations = mapView.annotations
        mapView.removeAnnotations(annotations)
        
        // Add a map pin
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        mapView.addAnnotation(pin)
        mapView.setRegion(
            MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(
                    latitudeDelta: 0.05,
                    longitudeDelta: 0.05
                )),
            animated: true
        )
    }
}

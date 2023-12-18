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

protocol POIResultPortocol: AnyObject {
    func didTapPlace(with coordinate: CLLocationCoordinate2D, targetPlace id: String)
}

class ExploreSiteViewController: UIViewController, CLLocationManagerDelegate {
    
    var delgate: POIResultPortocol?
    var id = ""
    var time = TimeInterval()
    
    var googlePlacesManager = GooglePlacesManager.shared
    var manager = CLLocationManager()
    var updateCount = 0
    
    // Google map
    var locationManager: CLLocationManager!
    var currentPhoto: GMSPlacePhotoMetadata?
    var currentLocation: CLLocation?
    var googleMapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var preciseLocationZoomLevel: Float = 15.0
    var approximateLocationZoomLevel: Float = 10.0
    
    // UI
    var bgImageView = UIImageView(image: UIImage(resource: .siteDetailFooter))
    var placeDetailView = UIView()
    var placeTitle = UILabel()
    var placeImageView = UIImageView()
    
    // Data
    var regionTags = [String]()
    var selectedLocation = Location(
        address: "None",
        shortName: "None",
        identifier: "None")
    
    var acceptButton = UIButton()
    let searchVC = UISearchController(searchResultsController: ResultViewController())
    var actionKind = ActionKind.add(1)
    
    // On event closure
    var onLocationComfirm: ( (Location, ActionKind) -> Void )?
    var onLocationComfirmMU: ( (Location, String, TimeInterval, ActionKind) -> Void )?
    var onLocationComfirmWithAddress: ( ([GMSAddressComponent]? ) -> Void )?
    
    // VM
    let viewModel = ExploreSiteViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.placeImage.bind { image in
            self.placeImageView.image = image
        }
        
        viewModel.regionTags.bind { tags in
            self.regionTags = tags
        }
        
        self.delgate = self
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
        
        bgImageView.clipsToBounds = true
        bgImageView.setCornerRadius(20)
            .contentMode = .scaleAspectFill
        
        placeTitle.text = "請選擇地點"
        placeTitle.font = UIFont(name: "ChalkboardSE-Regular", size: 16)
        placeTitle.setTextColor(.black)
            .textAlignment = .center
        
        // Customize detail view
        placeDetailView.setCornerRadius(20)
            .setbackgroundColor(.hexToUIColor(hex: "#DDDDDD"))
            .setBoarderWidth(2)
            .setBoarderColor(.hexToUIColor(hex: "#3F3A3A"))
        
        // Customize button
        acceptButton.setTitleColor(.white, for: .normal)
        acceptButton.setTarget(self, action: #selector(acceptButtonPressed), for: .touchUpInside)
            .setbackgroundColor(.hexToUIColor(hex: "#FF4E4E"))
            .setBoarderColor(.hexToUIColor(hex: "#3F3A3A"))
            .setBoarderWidth(1.5)
            .setCornerRadius(10)
            .setTitle("Confirm", for: .normal)
        
        // Customize image view
        placeImageView.image = UIImage(resource: .placeholder03)
        placeImageView.contentMode = .scaleAspectFill
        placeImageView.setBoarderColor(.hexToUIColor(hex: "#3F3A3A"))
            .setBoarderWidth(2.25)
            .setCornerRadius(25)
            .clipsToBounds = true
    }
    
    func addTo() {
        view.addSubviews([googleMapView])
        googleMapView.addSubviews([placeDetailView])
        placeDetailView.addSubviews([
            bgImageView,
            placeImageView,
            placeTitle,
            acceptButton])
    }
    
    func setupConstraint() {
        
        googleMapView.snp.makeConstraints { make in
            make.top.equalTo(view.snp_topMargin)
            make.bottom.equalTo(view.snp_bottomMargin)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        bgImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        placeDetailView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalTo(view.snp_bottomMargin).offset(-5)
            make.height.equalTo(120)
        }
        
        placeImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.width.equalTo(placeImageView.snp.height)
        }
        
        placeTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalTo(placeImageView.snp.trailing).offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.height.equalTo(20)
        }
        
        acceptButton.snp.makeConstraints { make in
            make.top.equalTo(placeTitle.snp.bottom).offset(20)
            make.leading.equalTo(placeImageView.snp.trailing).offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.height.equalTo(40)
        }
    }

    // MARK: - Accept button pressed
    @objc func acceptButtonPressed() {
        onLocationComfirmMU?(selectedLocation, id, time, actionKind)
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
        googleMapView.delegate = self
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

extension ExploreSiteViewController: ResultViewControllerDelegate, POIResultPortocol {
    
    func didTapPlace(with coordinate: CLLocationCoordinate2D, targetPlace id: String) {
        
        // viewModel.fetchPlaceInfo(identifier: id)
        
        Task {
            
            do {
                // Show
                LKProgressHUD.show()
                
                let place = try await self.googlePlacesManager.resolveLocation(for: id)
                
                guard let photoData = place.photos?.first else { return }
                self.currentPhoto = photoData
                
                let placeImage = try await self.googlePlacesManager.resolvePhoto(
                    from: photoData,
                    maxSize: CGSize(width: 512, height: 512))
                
                DispatchQueue.main.async {
                    self.placeImageView.image = placeImage
                }

                self.onLocationComfirmWithAddress?(place.addressComponents)
                
                let location = Location(
                    address: place.formattedAddress ?? "none",
                    shortName: place.name ?? "none",
                    identifier: id)
                
                self.selectedLocation = location
                self.selectedLocation.coordinate["lat"] = coordinate.latitude
                self.selectedLocation.coordinate["lng"] = coordinate.longitude
                
                self.placeTitle.text = self.selectedLocation.shortName
                
                // Hide keyboard and dismiss search VC
                self.searchVC.searchBar.resignFirstResponder()
                self.searchVC.dismiss(animated: true, completion: nil)
                
                // Set zoom level
                let zoomLevel = self.manager.accuracyAuthorization == .fullAccuracy ?
                self.preciseLocationZoomLevel : self.approximateLocationZoomLevel
                let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude,
                                                      longitude: coordinate.longitude,
                                                      zoom: zoomLevel)
                // Move to target
                self.googleMapView.animate(to: camera)
                
                // remove marker
                self.googleMapView.clear()
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude)
                marker.title = self.selectedLocation.shortName
                marker.snippet = self.selectedLocation.address
                marker.map = self.googleMapView
                
                // Dismiss
                LKProgressHUD.dismiss()
                
            } catch {
                print(error)
            }
        }
    }
    
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
        marker.snippet = targetPlace.address
        marker.map = googleMapView
    }
}

// MARK: - Google map delegate -
extension ExploreSiteViewController: GMSMapViewDelegate {
    
    // Get exsiting marker info
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        print("You tapped : \(marker.position.latitude),\(marker.position.longitude)")
        return true
    }
    
    // Get point of interest info
    func mapView(
      _ mapView: GMSMapView,
      didTapPOIWithPlaceID placeID: String,
      name: String,
      location: CLLocationCoordinate2D
    ) {
        print("You tapped \(name): \(placeID), \(location.latitude)/\(location.longitude)")
        
        DispatchQueue.main.async {
            self.delgate?.didTapPlace(with: location, targetPlace: placeID)
        }
    }
}

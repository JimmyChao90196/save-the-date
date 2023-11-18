//
//  PackageBaseVC.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/18.
//

import Foundation
import UIKit

import SnapKit
import CoreLocation

import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseCore

class PackageBaseViewController: UIViewController {
    
    var tableView = ModuleTableView()
    var packageManager = PackageManager.shared
    var googlePlaceManager = GooglePlacesManager.shared
    var firestoreManager = FirestoreManager.shared
    var routeManager = RouteManager.shared
    
    // On events
    var onDelete: ((UITableViewCell) -> Void)?
    var onLocationComfirm: ( (Location, ActionKind) -> Void )?
    var onLocationTapped: ((UITableViewCell) -> Void)?
    var onTranspTapped: ((UITableViewCell) -> Void)?
    var onTranspComfirm: ((TranspManager, ActionKind) -> Void)?
    
    // Current package
    var currentPackage = Package(convertFrom: [:])
    
    // Buttons
    var showRoute: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        
        button.backgroundColor = .blue
        button.setTitle("Show route", for: .normal)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPackageSource()
        
        addTo()
        setup()
        configureConstraint()
        setupOnEvent()
        
        // Set bar button
        let addBarButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonPressed))
        navigationItem.rightBarButtonItem = addBarButton
        
        let editBarButton = UIBarButtonItem(
            barButtonSystemItem: .edit,
            target: self,
            action: #selector(editButtonPressed))
        navigationItem.leftBarButtonItem = editBarButton
    }
    
    func addTo() {
        view.addSubviews([tableView, showRoute])
    }
    
    func setup() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.setEditing(false, animated: true)
        showRoute.addTarget(
            self,
            action: #selector(showRouteButtonPressed),
            for: .touchUpInside)
    }
    
    func setupPackageSource() {
        currentPackage = Package(
            info: Info(),
            packageModules: packageManager.packageModules)
    }
    
    func configureConstraint() {
        tableView.topConstr(to: view.safeAreaLayoutGuide.topAnchor, 0)
            .leadingConstr(to: view.safeAreaLayoutGuide.leadingAnchor, 0)
            .trailingConstr(to: view.safeAreaLayoutGuide.trailingAnchor, 0)
            .bottomConstr(to: view.safeAreaLayoutGuide.bottomAnchor, 0)

        showRoute.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.snp_bottomMargin).offset(-10)
            make.width.equalTo(100)
            make.height.equalTo(50)
        }
    }
}

// MARK: - dataSource method -
extension PackageBaseViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        currentPackage.packageModules.count
    }
    
    // Did select row at
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    // Cell for row at
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ModuleTableViewCell.reuseIdentifier,
            for: indexPath) as? ModuleTableViewCell else {
            return UITableViewCell() }
        
        let travelTime = currentPackage.packageModules[indexPath.row].transportation.travelTime
        let iconName = currentPackage.packageModules[indexPath.row].transportation.transpIcon
        let locationTitle = "\(packageManager.packageModules[indexPath.row].location.shortName)"
        
        cell.numberLabel.text = locationTitle
        cell.transpIcon.image = UIImage(systemName: iconName)
        cell.travelTimeLabel.text = formatTimeInterval(travelTime) == "none" ? "" : formatTimeInterval(travelTime)
        
        cell.onDelete = onDelete
        cell.onLocationTapped = self.onLocationTapped
        
        // Check if it's the last cell
        if indexPath.row == packageManager.packageModules.count - 1 {
            // Last cell
            cell.transpView.isHidden = true
            cell.onTranspTapped = nil
        } else {
            // Not the last cell
            cell.transpView.isHidden = false
            cell.onTranspTapped = self.onTranspTapped
        }
        return cell
    }
    
    // Can move row at
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    // Move row at
    func tableView(
        _ tableView: UITableView,
        moveRowAt sourceIndexPath: IndexPath,
        to destinationIndexPath: IndexPath) {
            
            self.packageManager.movePackage(from: sourceIndexPath, to: destinationIndexPath)
        }
}

// MARK: - Additional method -
extension PackageBaseViewController {
    
    // Interval formatter
    func formatTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = Int(interval) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)hr \(minutes)min"
        } else if minutes > 0 {
            return "\(minutes)min"
        } else {
            return "none"
        }
    }
    
    // Show route button pressed
    @objc func showRouteButtonPressed() {
        // Go to routeVC
        
        let locations = packageManager.packageModules.map { $0.location}
        
        let coords = locations.map {
            let coord = CLLocationCoordinate2D(
                latitude: $0.coordinate["lat"] ?? 0.0,
                longitude: $0.coordinate["lng"] ?? 0.0)
            return coord }
        
        let routeVC = RouteViewController()
        routeVC.coords = coords
        self.navigationController?.pushViewController(routeVC, animated: true)
    }
    
    // Add bar button pressed
    @objc func addButtonPressed() {
        // Go to Explore site and choose one
        let exploreVC = ExploreSiteViewController()
        exploreVC.onLocationComfirm = onLocationComfirm
        exploreVC.actionKind = .add
        navigationController?.pushViewController(exploreVC, animated: true)
    }
    
    // Edit bar button pressed
    @objc func editButtonPressed() {
        tableView.setEditing(!tableView.isEditing, animated: true)
    }
    
    // MARK: - Setup onEvents -
    func setupOnEvent() {
        
        onTranspTapped = { [weak self] cell in
            guard let self else { return }
            
            // Jump to transpVC
            let transpVC = TranspViewController()
            transpVC.onTranspComfirm = onTranspComfirm
            transpVC.actionKind = .edit(cell)
            self.navigationController?.pushViewController(transpVC, animated: true)
        }
        
        onLocationTapped = { [weak self] cell in
            guard let self else { return }
            
            let exploreVC = ExploreSiteViewController()
            exploreVC.onLocationComfirm = onLocationComfirm
            exploreVC.actionKind = .edit(cell)
            self.navigationController?.pushViewController(exploreVC, animated: true)
        }
        
        onLocationComfirm = { [weak self] location, action in
            // Dictate action
            
            let module = PackageModule(
                location: location,
                transportation: Transportation(
                    transpIcon: "plus.viewfinder",
                    travelTime: 0.0))
            
            switch action {
            case .add:
                self?.packageManager.addPackage(module)
            case .edit(let cell):
                guard let indexPathToEdit = self?.tableView.indexPath(for: cell) else { return }
                self?.packageManager.reviceLocation(replace: indexPathToEdit, with: location)
            }
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        onTranspComfirm = { [weak self] transp, action in
            // Dictate action
            
            switch action {
            case .add:
                print("this shouldn't be triggered")
                
            case .edit(let cell):
                guard let indexPathToEdit = self?.tableView.indexPath(for: cell) else { return }
                
                // Fetch source and dest coord
                let sourceCoordDic = self?.packageManager.packageModules[indexPathToEdit.row].location.coordinate
                let destCoordDic = self?.packageManager.packageModules[indexPathToEdit.row + 1].location.coordinate
                
                // Fetch travel time
                let sourceCoord = CLLocationCoordinate2D(
                    latitude: sourceCoordDic?["lat"] ?? 0,
                    longitude: sourceCoordDic?["lng"] ?? 0)
                
                let destCoord = CLLocationCoordinate2D(
                    latitude: destCoordDic?["lat"] ?? 0,
                    longitude: destCoordDic?["lng"] ?? 0)
                
                self?.routeManager.fetchTravelTime(
                    with: transp.transpType,
                    from: sourceCoord,
                    to: destCoord,
                    completion: { travelTime in
                        print(travelTime)
                        
                        let transportation = Transportation(
                            transpIcon: transp.transIcon,
                            travelTime: travelTime)
                        
                        // Replace with new transporation
                        self?.packageManager.reviceTransportation(relplace: indexPathToEdit, with: transportation)
                        
                        DispatchQueue.main.async {
                            self?.tableView.reloadData()
                        }
                    })
            }
        }
        
        onDelete = { [weak self] cell in
            guard let indexPathToDelete = self?.tableView.indexPath(for: cell) else { return }
            
            self?.packageManager.deletePackage(at: indexPathToDelete)
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
}

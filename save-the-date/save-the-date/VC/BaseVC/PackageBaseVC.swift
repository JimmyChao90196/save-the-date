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

enum WeatherState {
    case sunny
    case rainy
}

class PackageBaseViewController: UIViewController {
    
    // Current package
    var currentPackage = Package()
    var sunnyModules = [PackageModule]()
    var rainyModules = [PackageModule]()
    
    // Weather state can be switched
    var weatherState = WeatherState.sunny {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var tableView = ModuleTableView()
    var googlePlaceManager = GooglePlacesManager.shared
    var firestoreManager = FirestoreManager.shared
    var routeManager = RouteManager.shared
    
    // On events
    var onDelete: ((UITableViewCell) -> Void)?
    var onLocationComfirm: ( (Location, ActionKind) -> Void )?
    var onLocationTapped: ((UITableViewCell) -> Void)?
    var onTranspTapped: ((UITableViewCell) -> Void)?
    var onTranspComfirm: ((TranspManager, ActionKind) -> Void)?
    
    // Buttons
    var showRoute: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        
        button.backgroundColor = .blue
        button.setTitle("Show route", for: .normal)
        
        return button
    }()
    
    var switchWeatherButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 20))
        
        // Your logic to customize the button
        button.backgroundColor = .blue
        button.setTitle("Sunny", for: .normal)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTo()
        setup()
        configureConstraint()
        setupOnTapped()
        setupOnComfirm()
    }
    
    func addTo() {
        view.addSubviews([tableView, showRoute, switchWeatherButton])
    }
    
    func setup() {
        sunnyModules = currentPackage.weatherModules.sunny
        rainyModules = currentPackage.weatherModules.rainy
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.setEditing(false, animated: true)
        
        // Configure buttons
        showRoute.addTarget(
            self,
            action: #selector(showRouteButtonPressed),
            for: .touchUpInside)
        
        switchWeatherButton.addTarget(
            self,
            action: #selector(switchWeatherButtonPressed),
            for: .touchUpInside)
    }
    
    func configureConstraint() {
        tableView.topConstr(to: view.safeAreaLayoutGuide.topAnchor, 0)
            .leadingConstr(to: view.safeAreaLayoutGuide.leadingAnchor, 0)
            .trailingConstr(to: view.safeAreaLayoutGuide.trailingAnchor, 0)
            .bottomConstr(to: view.safeAreaLayoutGuide.bottomAnchor, 0)
        
        switchWeatherButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.snp_topMargin).offset(10)
        }

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
        switch weatherState {
        case .sunny:
            let totalDays = sunnyModules.compactMap { module in module.day }
            return totalDays.count
        case .rainy:
            let totalDays = rainyModules.compactMap { module in module.day }
            return totalDays.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch weatherState {
        
        case .sunny:
            return sunnyModules.filter { $0.day == section }.count
        case .rainy:
            return rainyModules.filter { $0.day == section }.count
        }
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
        
        var module = weatherState == .sunny ? sunnyModules : rainyModules
        module = module.filter { $0.day == indexPath.section }
        
        let travelTime = module[indexPath.row].transportation.travelTime
        let iconName = module[indexPath.row].transportation.transpIcon
        let locationTitle = "\(module[indexPath.row].location.shortName)"
        
        cell.numberLabel.text = locationTitle
        cell.transpIcon.image = UIImage(systemName: iconName)
        cell.travelTimeLabel.text = formatTimeInterval(travelTime) == "none" ? "" : formatTimeInterval(travelTime)
        
        cell.onDelete = onDelete
        cell.onLocationTapped = self.onLocationTapped
        
        // Check if it's the last cell
        
        if indexPath.row == module.count - 1 {
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
    
    // MARK: - Delegate method -
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = DayHeaderView()
        headerView.setDay(section)
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
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
            movePackage(from: sourceIndexPath, to: destinationIndexPath)
        }
}

// MARK: - Additional method -
extension PackageBaseViewController {
    
    // Function to find the correct index
    func findModuleIndex(modules: [PackageModule], day: Int, rowIndex: Int) -> Int? {
        var count = 0
        return modules.firstIndex { module in
            if module.day == day {
                if count == rowIndex {
                    return true
                }
                count += 1
            }
            return false
        }
    }
    
    // Logic to swap module
    func movePackage(from source: IndexPath, to destination: IndexPath) {
        
        if weatherState == .sunny {
            let movedObject = sunnyModules[source.row]
            sunnyModules.remove(at: source.row)
            sunnyModules.insert(movedObject, at: destination.row)
        } else {
            let movedObject = rainyModules[source.row]
            rainyModules.remove(at: source.row)
            rainyModules.insert(movedObject, at: destination.row)
        }
    }
    
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
    // Switch weather button pressed
    @objc func switchWeatherButtonPressed() {
        if weatherState == .sunny {
            switchWeatherButton.setTitle("Rainy", for: .normal)
            weatherState = .rainy
        } else {
            switchWeatherButton.setTitle("Sunny", for: .normal)
            weatherState = .sunny
        }

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // Show route button pressed
    @objc func showRouteButtonPressed() {
        // Go to routeVC
        
        let locations = weatherState == .sunny ? 
        sunnyModules.map { $0.location}: rainyModules.map { $0.location }
        
        let coords = locations.map {
            let coord = CLLocationCoordinate2D(
                latitude: $0.coordinate["lat"] ?? 0.0,
                longitude: $0.coordinate["lng"] ?? 0.0)
            return coord }
        
        let routeVC = RouteViewController()
        routeVC.coords = coords
        self.navigationController?.pushViewController(routeVC, animated: true)
    }
    
    // MARK: - Setup onEvents -
    func setupOnComfirm() {
        onLocationComfirm = { [weak self] location, action in
            let module = PackageModule(
                location: location,
                transportation: Transportation(
                    transpIcon: "plus.viewfinder",
                    travelTime: 0.0))
            
            switch action {
            case .add:
                
                if self?.weatherState == .sunny {
                    self?.sunnyModules.append(module)
                } else {
                    self?.rainyModules.append(module)
                }
                
            case .edit(let cell):
                
                guard let indexPathToEdit = self?.tableView.indexPath(for: cell) else { return }
                let targetDay = indexPathToEdit.section
                let rowIndexForDay = indexPathToEdit.row

                if self?.weatherState == .sunny {
                    if let index = self?.findModuleIndex(
                        modules: self?.sunnyModules ?? [],
                        day: targetDay, rowIndex: rowIndexForDay) {
                        self?.sunnyModules[index].location = location
                    }
                } else {
                    if let index = self?.findModuleIndex(
                        modules: self?.rainyModules ?? [],
                        day: targetDay, rowIndex: rowIndexForDay) {
                        self?.rainyModules[index].location = location
                    }
                }
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
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
                let sourceCoordDic = self?.weatherState == .sunny ?
                self?.sunnyModules[indexPathToEdit.row].location.coordinate:
                self?.rainyModules[indexPathToEdit.row].location.coordinate
                
                let destCoordDic = self?.weatherState == .sunny ?
                self?.sunnyModules[indexPathToEdit.row + 1].location.coordinate:
                self?.rainyModules[indexPathToEdit.row + 1].location.coordinate
                
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
                        if self?.weatherState == .sunny {
                            self?.sunnyModules[indexPathToEdit.row].transportation = transportation
                        } else {
                            self?.rainyModules[indexPathToEdit.row].transportation = transportation
                        }
                        
                        DispatchQueue.main.async {
                            self?.tableView.reloadData()
                        }
                    })
            }
        }
    }
    
    func setupOnTapped() {
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
        
        onDelete = { [weak self] cell in
            guard let indexPathToDelete = self?.tableView.indexPath(for: cell) else { return }
            
            if self?.weatherState == .sunny {
                self?.currentPackage.weatherModules.sunny.remove(at: indexPathToDelete.row)
            } else {
                self?.currentPackage.weatherModules.rainy.remove(at: indexPathToDelete.row)
            }
                
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
}

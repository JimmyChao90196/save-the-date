//
//  PackageBaseVC.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/18.
//

import Foundation
import UIKit
import SwiftUI

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
    
    // Session
    var sessionID = ""
    var isMultiUser = false {
        didSet {
            print("isMulti-user: \(isMultiUser)")
        }
    }
    
    // User
    var userID = "red@gamil.com"
    
    // Current package
    var currentPackage = Package()
    var sunnyModules = [PackageModule]() {
        didSet {
            changeBGImage()
        }
    }
    var rainyModules = [PackageModule]() {
        didSet {
            changeBGImage()
        }
    }
    
    // Weather state can be switched
    var weatherState = WeatherState.sunny {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // UI
    var segControl = UISegmentedControl(items: ["Sunny", "Rainy"])
    var tableView = ModuleTableView()
    var bgImageView = UIImageView(image: UIImage(resource: .createBG02))
    var bgView = UIView()
    var googlePlaceManager = GooglePlacesManager.shared
    var firestoreManager = FirestoreManager.shared
    var routeManager = RouteManager.shared
    
    // On events
    var onDelete: ((UITableViewCell) -> Void)?
    var onLocationComfirm: ( (Location, ActionKind) -> Void )?
    var onLocationTapped: ((UITableViewCell) -> Void)?
    var onTranspTapped: ((UITableViewCell) -> Void)?
    var onTranspComfirm: ((TranspManager, ActionKind) -> Void)?
    var onAddModulePressed: ((Int) -> Void)?
    
    // after events
    var afterLocationComfirmed: ((Int) -> Void)?
    var afterAppendLocationComfirmed: ((PackageModule) -> Void)?
    
    // Buttons
    var showRoute: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 25))
        
        button.backgroundColor = .white
        button.setCornerRadius(12.5)
            .setBoarderWidth(2.5)
            .setBoarderColor(.lightGray)
            .setTitleColor(.black, for: .normal)
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
        view.addSubviews([
            bgView,
            bgImageView,
            tableView,
            showRoute,
            switchWeatherButton,
            segControl])
    }
    
    func setup() {
        sunnyModules = currentPackage.weatherModules.sunny
        rainyModules = currentPackage.weatherModules.rainy
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.setEditing(false, animated: true)
        tableView.sectionHeaderTopPadding = 0.0
        
        // Configure buttons
        showRoute.addTarget(
            self,
            action: #selector(showRouteButtonPressed),
            for: .touchUpInside)
        
        segControl.addTarget(
            self,
            action: #selector(segmentChanged(_:)),
            for: .valueChanged)
        
        // Appearance of segment control
        let normalTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        segControl.setTitleTextAttributes(normalTextAttributes, for: .normal)

        let selectedTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        segControl.setTitleTextAttributes(selectedTextAttributes, for: .selected)
        segControl.selectedSegmentIndex = 0
        segControl.backgroundColor = UIColor.hexToUIColor(hex: "#FF4E4E")
        
        segControl.setBoarderWidth(2)
            .setBoarderColor(.hexToUIColor(hex: "#3F3A3A"))
            .selectedSegmentTintColor = .black
        
        changeBGImage()
    }
    
    func configureConstraint() {
        tableView.topConstr(to: view.safeAreaLayoutGuide.topAnchor, 0)
            .leadingConstr(to: view.safeAreaLayoutGuide.leadingAnchor, 0)
            .trailingConstr(to: view.safeAreaLayoutGuide.trailingAnchor, 0)
            .bottomConstr(to: view.safeAreaLayoutGuide.bottomAnchor, 0)
        
        bgView.snp.makeConstraints { make in
            make.edges.equalTo(self.tableView)
        }
        
        bgImageView.snp.makeConstraints { make in
            make.edges.equalTo(self.tableView)
        }
        
        segControl.snp.makeConstraints { make in
            make.top.equalTo(view.snp_topMargin).offset(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(140)
        }

        showRoute.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.snp_bottomMargin).offset(-10)
            make.width.equalTo(100)
            make.height.equalTo(25)
        }
    }
}

// MARK: - dataSource method -
extension PackageBaseViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch weatherState {
        case .sunny:
            let totalDays = sunnyModules.compactMap { module in module.day }
            guard let lastDay = totalDays.max() else { return 0 }
            return lastDay + 1
        case .rainy:
            let totalDays = rainyModules.compactMap { module in module.day }
            guard let lastDay = totalDays.max() else { return 0 }
            return lastDay + 1
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
        
        let module = weatherState == .sunny ? sunnyModules : rainyModules
        
        guard let rawIndex = findModuleIndex(modules: module, from: indexPath) else {return UITableViewCell()}
        
        let travelTime = module[rawIndex].transportation.travelTime
        let iconName = module[rawIndex].transportation.transpIcon
        let locationTitle = "\(module[rawIndex].location.shortName)"
        
        // Location title
        cell.siteTitle.text = locationTitle
        
        // Transp Icon
        let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
        cell.transpIcon.image = UIImage(systemName: iconName, withConfiguration: config)
        cell.transpIcon.tintColor = .lightGray
        cell.transpIcon.contentMode = .scaleAspectFit
        
        let cellUserId = module[rawIndex].lockInfo.userId
        
        if cellUserId == userID {
            // Claimed by me already
            cell.locationView.setBoarderColor(.green)
            cell.onLocationTapped = self.onLocationTapped
            
        } else if cellUserId == "" {
            // Unclaimed
            cell.onLocationTapped = self.onLocationTapped
            
        } else {
            // Claimed by others
            cell.locationView.setBoarderColor(.hexToUIColor(hex: "#CCCCCC"))
            cell.onLocationTapped = nil
        }
        
        // Travel time label
        cell.travelTimeLabel.text = formatTimeInterval(travelTime)
        
        // ImageBG
        switch weatherState {
        case .sunny:
            cell.bgImageView.image = UIImage(resource: .site04)
            cell.bgImageView.contentMode = .scaleAspectFit
        case .rainy:
            cell.bgImageView.image = UIImage(resource: .site05)
            cell.bgImageView.contentMode = .scaleAspectFit
        }
        
        // Find last cell
        let totalSections = tableView.numberOfSections
        let totalRowsInLastSection = tableView.numberOfRows(inSection: totalSections - 1)
        let isLastCell = indexPath.section == totalSections - 1 && indexPath.row == totalRowsInLastSection - 1
        
        if isLastCell {
            cell.onTranspTapped = nil
            cell.transpView.isHidden = true
        } else {
            cell.onTranspTapped = self.onTranspTapped
            cell.transpView.isHidden = false
        }
        
        return cell
    }
    
    // MARK: - Delegate method -
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let headerView = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: DayHeaderView.reuseIdentifier) as? DayHeaderView else { return UIView()}
        
        headerView.section = section
        headerView.onAddModulePressed = self.onAddModulePressed
        headerView.setDay(section)
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // Delete logic
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Perform deletion of the item from your data source
            
            if self.weatherState == .sunny {
                let rawIndexForModule = self.findModuleIndex(
                    modules: self.sunnyModules,
                    from: indexPath)
                
                // Is in multi-user mode or not
                if self.isMultiUser {
                    self.firestoreManager.deleteModuleWithTrans(
                        packageId: self.sessionID,
                        targetIndex: rawIndexForModule ?? 0,
                        with: self.currentPackage) { newPackage in
                            self.currentPackage = newPackage
                            self.sunnyModules = newPackage.weatherModules.sunny
                        }
                    
                } else {
                    
                    self.sunnyModules.remove(at: rawIndexForModule ?? 0)
                }
                
            } else {
                let rawIndexForModule = self.findModuleIndex(
                    modules: self.rainyModules,
                    from: indexPath)
                
                // Is in multi-user mode or not
                if self.isMultiUser {
                    
                } else {
                    self.rainyModules.remove(at: rawIndexForModule ?? 0)
                }
            }
                
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
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
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    
    // Fix gap
    func tableView(
        _ tableView: UITableView,
        heightForFooterInSection section: Int) -> CGFloat {
        CGFloat.leastNormalMagnitude
    }
}

// MARK: - Additional method -
extension PackageBaseViewController {
    
    func changeBGImage() {
        DispatchQueue.main.async {
            self.bgImageView.contentMode = .scaleAspectFit
            self.bgView.backgroundColor = .hexToUIColor(hex: "#E5E5E5")
            
            switch self.weatherState {
            case .sunny:
                if self.sunnyModules.isEmpty {
                    self.bgImageView.image = UIImage(resource: .createBG02)
                } else {
                    self.bgImageView.image = UIImage(resource: .createBG03)
                }
            case .rainy:
                if self.rainyModules.isEmpty {
                    self.bgImageView.image = UIImage(resource: .createBG02)
                } else {
                    self.bgImageView.image = UIImage(resource: .createBG03)
                }
            }
        }
    }
    
    // Find next indexPath
    func findNextIndexPath(currentCell: UITableViewCell, in tableView: UITableView) -> IndexPath? {
        guard let indexPath = tableView.indexPath(for: currentCell) else { return nil }

        let currentSection = indexPath.section
        let currentRow = indexPath.row
        let totalSections = tableView.numberOfSections

        // Check if the next cell is in the same section
        if currentRow < tableView.numberOfRows(inSection: currentSection) - 1 {
            return IndexPath(row: currentRow + 1, section: currentSection)
        }
        // Check if there's another section
        else if currentSection < totalSections - 1 {
            return IndexPath(row: 0, section: currentSection + 1)
        }
        
        // No next cell (current cell is the last cell of the last section)
        return nil
    }
    
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
    
    func findModuleIndex(modules: [PackageModule], from indexPath: IndexPath) -> Int? {
        var count = 0
        let moduleDay = indexPath.section
        let row = indexPath.row
        
        return modules.firstIndex { module in
            if module.day == moduleDay {
                if count == row { return true }
                count += 1
            }
            return false
        }
    }
    
    func findModuleIndecies(
        modules: [PackageModule],
        targetModuleDay: Int,
        rowIndex: Int,
        nextModuleDay: Int,
        nextRowIndex: Int,
        completion: (Int?, Int?) -> Void) {
            
            // Target index
            var targetCount = 0
            let targetIndext = modules.firstIndex { module in
                if module.day == targetModuleDay {
                    if targetCount == rowIndex { return true }
                    targetCount += 1
                }
                return false
            }
            
            // Next index
            var nextCount = 0
            let nextIndext = modules.firstIndex { module in
                if module.day == nextModuleDay {
                    
                    if nextCount == nextRowIndex { return true }
                    nextCount += 1
                }
                return false
            }
            completion(targetIndext, nextIndext)
        }
    
    // Logic to swap module
    func movePackage(from source: IndexPath, to destination: IndexPath) {
        
        if weatherState == .sunny {
            
            // First find out the "raw" index of the module
            guard let sourceRowIndex = findModuleIndex(
                modules: sunnyModules,
                from: source) else {return}
            guard let destRowIndex = findModuleIndex(
                modules: sunnyModules,
                from: destination) else {return}
            
            // is in multi-user mode?
            if isMultiUser == true {
                
                currentPackage.weatherModules.sunny = sunnyModules
                
                self.firestoreManager.swapModulesWithTrans(
                    packageId: sessionID,
                    sourceIndex: sourceRowIndex,
                    destIndex: destRowIndex,
                    with: currentPackage) { currentPackage in
                        
                        self.currentPackage = currentPackage
                        self.sunnyModules = currentPackage.weatherModules.sunny
                    }
                
            } else {
                sunnyModules.swapAt(sourceRowIndex, destRowIndex)
            }
            
        } else {
            
            if isMultiUser == true {
                
            } else {
                
                guard let sourceRowIndex = findModuleIndex(
                    modules: rainyModules,
                    from: source) else {return}
                guard let destRowIndex = findModuleIndex(
                    modules: rainyModules,
                    from: destination) else {return}
                
                sunnyModules.swapAt(sourceRowIndex, destRowIndex)
            }
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
            return "0 min"
        }
    }
    
    // Segment control changed
    @objc func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            print("It's sunny")
            weatherState = .sunny
            
        case 1:
            weatherState = .rainy
            print("It's rainy")
        default:
            break
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
            
            switch action {
            case .add(let section):
                
                let module = PackageModule(
                    location: location,
                    transportation: Transportation(
                        transpIcon: "plus.viewfinder",
                        travelTime: 0.0),
                    day: section)
                
                if self?.weatherState == .sunny {
                    self?.sunnyModules.append(module)
                    
                    // When in multi-user mode
                    if self?.isMultiUser == true {
                        self?.afterAppendLocationComfirmed?(module)
                    }
                    
                } else {
                    self?.rainyModules.append(module)
                }
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                
            case .edit(let cell):

                if self?.weatherState == .sunny {
                    guard let indexPathToEdit = self?.tableView.indexPath(for: cell) else { return }
                    
                    if let index = self?.findModuleIndex(
                        modules: self?.sunnyModules ?? [],
                        from: indexPathToEdit) {
                        self?.sunnyModules[index].location = location
                        
                        if self?.isMultiUser == true {
                            self?.afterLocationComfirmed?(index)
                        }
                    }
                    
                } else {
                    guard let indexPathToEdit = self?.tableView.indexPath(for: cell) else { return }
                    
                    if let index = self?.findModuleIndex(
                        modules: self?.rainyModules ?? [],
                        from: indexPathToEdit) {
                        self?.rainyModules[index].location = location
                        
                        // When in multi-user mode
                        if self?.isMultiUser == true {
                            self?.afterLocationComfirmed?(index)
                        }
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
                
                // Fetch source and dest coord
                guard let self else {return}
                guard let indexPathToEdit = self.tableView.indexPath(for: cell) else { return }
                guard let nextIndexPath = self.findNextIndexPath(currentCell: cell, in: self.tableView) else { return }
                
                let targetDay = indexPathToEdit.section
                let rowIndexForDay = indexPathToEdit.row
                
                let nextDay = nextIndexPath.section
                let nextRowIndexForDay = nextIndexPath.row
                
                var sourceCoordDic = [String: Double]()
                var destCoordDic = [String: Double]()
                
                if self.weatherState == .sunny {
                    
                    findModuleIndecies(
                        modules: self.sunnyModules,
                        targetModuleDay: targetDay,
                        rowIndex: rowIndexForDay,
                        nextModuleDay: nextDay,
                        nextRowIndex: nextRowIndexForDay) { targetIndex, nextIndex in
                            sourceCoordDic = self.sunnyModules[targetIndex ?? 0].location.coordinate
                            destCoordDic = self.sunnyModules[nextIndex ?? 0].location.coordinate
                        }
                    
                } else {
                    
                    findModuleIndecies(
                        modules: self.rainyModules,
                        targetModuleDay: targetDay,
                        rowIndex: rowIndexForDay,
                        nextModuleDay: nextDay,
                        nextRowIndex: nextRowIndexForDay) { targetIndex, nextIndex in
                        sourceCoordDic = self.rainyModules[targetIndex ?? 0].location.coordinate
                        destCoordDic = self.rainyModules[nextIndex ?? 0].location.coordinate
                    }
                }
                
                // Fetch travel time
                let sourceCoord = CLLocationCoordinate2D(
                    latitude: sourceCoordDic["lat"] ?? 0,
                    longitude: sourceCoordDic["lng"] ?? 0)
                
                let destCoord = CLLocationCoordinate2D(
                    latitude: destCoordDic["lat"] ?? 0,
                    longitude: destCoordDic["lng"] ?? 0)
                
                self.routeManager.fetchTravelTime(
                    with: transp.transpType,
                    from: sourceCoord,
                    to: destCoord,
                    completion: { travelTime in
                        print(travelTime)
                        
                        let transportation = Transportation(
                            transpIcon: transp.transIcon,
                            travelTime: travelTime)
                        
                        // Replace with new transporation
                        if self.weatherState == .sunny {
                            if let index = self.findModuleIndex(
                                modules: self.sunnyModules,
                                from: indexPathToEdit) {
                                self.sunnyModules[index].transportation = transportation
                            }
                        } else {
                            if let index = self.findModuleIndex(
                                modules: self.rainyModules,
                                from: indexPathToEdit) {
                                self.rainyModules[index].transportation = transportation
                            }
                        }
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    })
            }
        }
    }
    
    func setupOnTapped() {
        onAddModulePressed = { [weak self] section in
            // Go to Explore site and choose one
            
            print("orig: \(section)")
            
            let exploreVC = ExploreSiteViewController()
            exploreVC.onLocationComfirm = self?.onLocationComfirm
            exploreVC.actionKind = .add(section)
            self?.navigationController?.pushViewController(exploreVC, animated: true)
        }
        
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
            
            if isMultiUser {
                let indexPath = self.tableView.indexPath(for: cell) ?? IndexPath()
                guard let rawIndex = findModuleIndex(
                    modules: sunnyModules,
                    from: indexPath) else { return }
                
                self.firestoreManager.lockModuleWithTrans(
                    packageId: self.sessionID,
                    userId: userID,
                    targetIndex: rawIndex,
                    with: self.currentPackage) { newPackage in
                        self.currentPackage = newPackage
                        self.sunnyModules = newPackage.weatherModules.sunny
                    }
                
                // Go to explore
                let exploreVC = ExploreSiteViewController()
                exploreVC.onLocationComfirm = self.onLocationComfirm
                exploreVC.actionKind = .edit(cell)
                self.navigationController?.pushViewController(exploreVC, animated: true)
                
            } else {
                
                // Go to explore
                let exploreVC = ExploreSiteViewController()
                exploreVC.onLocationComfirm = self.onLocationComfirm
                exploreVC.actionKind = .edit(cell)
                self.navigationController?.pushViewController(exploreVC, animated: true)
            }
        }
    }
}

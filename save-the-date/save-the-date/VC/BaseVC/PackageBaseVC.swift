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
    var userName = "Jimmy"
    
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
    
    // Manager
    var googlePlaceManager = GooglePlacesManager.shared
    var firestoreManager = FirestoreManager.shared
    var routeManager = RouteManager.shared
    
    // On events
    var onDelete: ((UITableViewCell) -> Void)?
    var onLocationComfirm: ( (Location, ActionKind) -> Void )?
    var onLocationComfirmMU: ( (Location, String, TimeInterval, ActionKind) -> Void )?
    
    var onLocationTapped: ((UITableViewCell) -> Void)?
    var onTranspTapped: ((UITableViewCell) -> Void)?
    var onTranspComfirm: ((TranspManager, ActionKind, TimeInterval) -> Void)?
    var onAddModulePressed: ((Int) -> Void)?
    
    // after events
    var afterEditComfirmed: ((Int, TimeInterval) -> Void)?
    var afterAppendComfirmed: ((PackageModule) -> Void)?
    
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
        button.backgroundColor = .white
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
        cell.transpIcon.contentMode = .scaleAspectFit
        
        // Find last cell, and handel visibility
        let totalSections = tableView.numberOfSections
        let totalRowsInLastSection = tableView.numberOfRows(inSection: totalSections - 1)
        let isLastCell = indexPath.section == totalSections - 1 && indexPath.row == totalRowsInLastSection - 1
        
        if isLastCell {
            cell.onTranspTapped = nil
            cell.transpView.isHidden = true
        } else {
            cell.transpView.isHidden = false
        }
        
        // Handle location and transportation tapped
        let cellUserId = module[rawIndex].lockInfo.userId
        
        if cellUserId != "" {
            cell.userIdLabel.text = cellUserId.components(separatedBy: "@")[0]
            
        } else {
            cell.userIdLabel.text = ""
            
        }
        
        if cellUserId == userID {
            // Claimed by me already
            cell.userIdLabel.isHidden = false
            cell.userIdLabel.setbackgroundColor(.black)
            cell.locationView.setBoarderColor(.black)
            cell.userIdLabel.setTextColor(.white)
            cell.transpIcon.tintColor = .lightGray
            cell.travelTimeLabel.setTextColor(.darkGray)
            
            cell.siteTitle.setTextColor(.hexToUIColor(hex: "#3F3A3A"))
            cell.arrivedTimeLabel.setTextColor(.hexToUIColor(hex: "#3F3A3A"))
            
            cell.onLocationTapped = self.onLocationTapped
            cell.onTranspTapped = self.onTranspTapped
            
            cell.contentView.setBoarderColor(.clear)
            
        } else if cellUserId == "" {
            // Unclaimed
            cell.userIdLabel.isHidden = true
            cell.locationView.setBoarderColor(.hexToUIColor(hex: "#AAAAAA"))
            cell.transpIcon.tintColor = .lightGray
            cell.travelTimeLabel.setTextColor(.darkGray)
            
            cell.siteTitle.setTextColor(.hexToUIColor(hex: "#3F3A3A"))
            cell.arrivedTimeLabel.setTextColor(.hexToUIColor(hex: "#3F3A3A"))
            
            cell.onLocationTapped = self.onLocationTapped
            cell.onTranspTapped = self.onTranspTapped
            
            cell.contentView.setBoarderColor(.clear)
            
        } else {
            // Claimed by others
            cell.userIdLabel.isHidden = false
            cell.userIdLabel.setbackgroundColor(.hexToUIColor(hex: "#DADADA"))
            cell.userIdLabel.setTextColor(.black)
            cell.locationView.setBoarderColor(.hexToUIColor(hex: "#DADADA"))
            cell.transpIcon.tintColor = .hexToUIColor(hex: "#DADADA")
            cell.travelTimeLabel.setTextColor(.hexToUIColor(hex: "DADADA"))
            
            cell.siteTitle.setTextColor(.hexToUIColor(hex: "#DADADA"))
            cell.arrivedTimeLabel.setTextColor(.hexToUIColor(hex: "#DADADA"))
            
            cell.onLocationTapped = nil
            cell.onTranspTapped = nil
            
            cell.contentView.setBoarderColor(.hexToUIColor(hex: "#DADADA"))
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
            
            let rawIndex = findModuleIndex(modules: self.sunnyModules, from: indexPath)
            let id = self.sunnyModules[rawIndex ?? 0].lockInfo.userId
            if id != "" && id != "none" && id != "None" && id != userID {
                return
            }
            
            // Perform deletion of the item from your data source
            if self.weatherState == .sunny {
                
                let rawIndexForModule = self.findModuleIndex(
                    modules: self.sunnyModules,
                    from: indexPath)
                let time = self.sunnyModules[rawIndexForModule ?? 0].lockInfo.timestamp
                
                // Is in multi-user mode or not
                if self.isMultiUser {
                    
                    // Delete first
                    self.sunnyModules.remove(at: rawIndexForModule ?? 0)
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                    self.firestoreManager.deleteModuleWithTrans(
                        
                        packageId: self.sessionID,
                        time: time,
                        targetIndex: rawIndexForModule ?? 0,
                        with: self.currentPackage,
                        when: .sunny
                    ) { newPackage in
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
                let time = self.rainyModules[rawIndexForModule ?? 0].lockInfo.timestamp
                
                // Is in multi-user mode or not
                if self.isMultiUser {
                    
                    // Delete first
                    self.rainyModules.remove(at: rawIndexForModule ?? 0)
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                    self.firestoreManager.deleteModuleWithTrans(
                        
                        packageId: self.sessionID,
                        time: time,
                        targetIndex: rawIndexForModule ?? 0,
                        with: self.currentPackage,
                        when: .rainy
                    ) { newPackage in
                            self.currentPackage = newPackage
                            self.sunnyModules = newPackage.weatherModules.sunny
                        }
                    
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
        let rawIndex = findModuleIndex(modules: self.sunnyModules, from: indexPath)
        let id = self.sunnyModules[rawIndex ?? 0].lockInfo.userId
        
        if id != "" && id != "none" && id != "None" && id != userID {
            return false
        } else {
            return true
        }
        
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
        
        self.bgImageView.contentMode = .scaleAspectFit
        self.bgView.backgroundColor = .hexToUIColor(hex: "#E5E5E5")
        self.tableView.contentMode = .scaleAspectFit
        
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
    
    // Find next
    func findNextIndexPath(
        currentIndex indexPath: IndexPath,
        in tableView: UITableView) -> IndexPath? {
        
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
                
                // Swap first
                sunnyModules.swapAt(sourceRowIndex, destRowIndex)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
                self.firestoreManager.swapModulesWithTrans(
                    packageId: sessionID,
                    sourceIndex: sourceRowIndex,
                    destIndex: destRowIndex,
                    with: currentPackage,
                    when: .sunny
                ) { currentPackage in
                        
                        self.currentPackage = currentPackage
                        self.sunnyModules = currentPackage.weatherModules.sunny
                    }
                
            } else {
                sunnyModules.swapAt(sourceRowIndex, destRowIndex)
            }
            
        } else {
            
            // First find out the "raw" index of the module
            guard let sourceRowIndex = findModuleIndex(
                modules: rainyModules,
                from: source) else {return}
            guard let destRowIndex = findModuleIndex(
                modules: rainyModules,
                from: destination) else {return}
            
            // is in multi-user mode?
            if isMultiUser == true {
                
                currentPackage.weatherModules.rainy = rainyModules
                
                // Swap first
                rainyModules.swapAt(sourceRowIndex, destRowIndex)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
                self.firestoreManager.swapModulesWithTrans(
                    packageId: sessionID,
                    sourceIndex: sourceRowIndex,
                    destIndex: destRowIndex,
                    with: currentPackage,
                    when: .rainy
                ) { currentPackage in
                        
                        self.currentPackage = currentPackage
                        self.rainyModules = currentPackage.weatherModules.rainy
                    }
                
            } else {
                rainyModules.swapAt(sourceRowIndex, destRowIndex)
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
        
        onLocationComfirmMU = { [weak self] location, id, time, actionKind in
            switch actionKind {
            case .add( let section ):
                
                if self?.weatherState == .sunny {
                    let module = PackageModule(
                        location: location,
                        transportation: Transportation(
                            transpIcon: "plus.viewfinder",
                            travelTime: 0.0),
                        day: section)
                    
                    self?.sunnyModules.append(module)
                    self?.afterAppendComfirmed?(module)
                    
                } else {
                    let module = PackageModule(
                        location: location,
                        transportation: Transportation(
                            transpIcon: "plus.viewfinder",
                            travelTime: 0.0),
                        day: section)
                    
                    self?.rainyModules.append(module)
                    self?.afterAppendComfirmed?(module)
                }
                
            case .edit(_):
                if self?.weatherState == .sunny {
                    
                    if let rawIndex = self?.sunnyModules.firstIndex(where: {
                        if $0.lockInfo.userId == id && $0.lockInfo.timestamp == time {
                            return true
                        } else { return false }
                        
                    }) {
                        self?.sunnyModules[rawIndex].location = location
                        self?.afterEditComfirmed?(rawIndex, time)
                    }
                    
                } else {
                    
                    if let rawIndex = self?.rainyModules.firstIndex(where: {
                        if $0.lockInfo.userId == id && $0.lockInfo.timestamp == time {
                            return true
                        } else { return false }
                        
                    }) {
                        self?.rainyModules[rawIndex].location = location
                        self?.afterEditComfirmed?(rawIndex, time)
                    }
                }
            }
        }
        
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
                    
                } else {
                    self?.rainyModules.append(module)
                }
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                
            case .edit(let targetIndex):

                if self?.weatherState == .sunny {
                    
                    if let index = self?.findModuleIndex(
                        modules: self?.sunnyModules ?? [],
                        from: targetIndex) {
                        self?.sunnyModules[index].location = location
                    }
                    
                } else {
                    
                    if let index = self?.findModuleIndex(
                        modules: self?.rainyModules ?? [],
                        from: targetIndex) {
                        self?.rainyModules[index].location = location
                    }
                }
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
        
        onTranspComfirm = { [weak self] transp, action, time in
            
            // Show loading
            LKProgressHUD.show()
            
            // Dictate action
            switch action {
            case .add:
                print("this shouldn't be triggered")
                
            case .edit( let targetIndex ):
                
                guard let self else { return }

                // Prepare source and dest
                var sourceCoordDic = [String: Double]()
                var destCoordDic = [String: Double]()
                
                var sunnySourceRawIndex = 0
                var sunnyDestRawIndex = 0
                
                var rainySourceRawIndex = 0
                var rainyDestRawIndex = 0
                
                if self.weatherState == .sunny {
                    
                    let rawDestIndexPath = findNextIndexPath(currentIndex: targetIndex, in: self.tableView)
                    
                    sunnySourceRawIndex = findModuleIndex(
                        modules: self.sunnyModules,
                        from: targetIndex) ?? 0
                    
                    sunnyDestRawIndex = findModuleIndex(
                        modules: self.sunnyModules,
                        from: rawDestIndexPath ?? IndexPath()) ?? 0
                    
                    sourceCoordDic = self.sunnyModules[sunnySourceRawIndex].location.coordinate
                    destCoordDic = self.sunnyModules[sunnyDestRawIndex].location.coordinate
                    
                } else {
                    
                    let rawDestIndexPath = findNextIndexPath(currentIndex: targetIndex, in: self.tableView)
                    
                    rainySourceRawIndex = findModuleIndex(
                        modules: self.rainyModules,
                        from: targetIndex) ?? 0
                    
                    rainyDestRawIndex = findModuleIndex(
                        modules: self.rainyModules,
                        from: rawDestIndexPath ?? IndexPath()) ?? 0
                    
                    sourceCoordDic = self.rainyModules[rainySourceRawIndex].location.coordinate
                    destCoordDic = self.rainyModules[rainyDestRawIndex].location.coordinate
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
                            
                            self.sunnyModules[sunnySourceRawIndex].transportation = transportation
                            
                            // When in multi-user
                            if self.isMultiUser {
                                self.afterEditComfirmed?(sunnySourceRawIndex, time)
                            }
                            
                        } else {
                            
                            self.rainyModules[rainySourceRawIndex].transportation = transportation
                            
                            // When in multi-user
                            if self.isMultiUser {
                                self.afterEditComfirmed?(rainySourceRawIndex, time)
                            }
                        }
                        
                        // Dissmiss loading
                        LKProgressHUD.dismiss()
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    })
            }
        }
    }
    
    func setupOnTapped() {
        
        onAddModulePressed = { section in
            // Go to Explore site and choose one
            print("orig: \(section)")
            
            let exploreVC = ExploreSiteViewController()
            
            if self.isMultiUser {
                
                exploreVC.actionKind = .add(section)
                exploreVC.onLocationComfirmMU = self.onLocationComfirmMU
                
            } else {
                
                exploreVC.onLocationComfirm = self.onLocationComfirm
            }
            
            exploreVC.actionKind = .add(section)
            self.navigationController?.pushViewController(exploreVC, animated: true)
            
        }
        
        onTranspTapped = { [weak self] cell in
            guard let indexPath = self?.tableView.indexPath(for: cell),
            let self = self else { return }
            
            // Show loading
            LKProgressHUD.show()
            
            var rawIndex = 0
            var time = 0.0
            var id = ""
            
            // Find time first
            if weatherState == .sunny {
                rawIndex = findModuleIndex(modules: sunnyModules, from: indexPath) ?? 0
                time = self.sunnyModules[rawIndex].lockInfo.timestamp
            } else {
                rawIndex = findModuleIndex(modules: rainyModules, from: indexPath) ?? 0
                time = self.rainyModules[rawIndex].lockInfo.timestamp
            }
            
            if isMultiUser {
                self.firestoreManager.lockModuleWithTrans(
                    packageId: self.sessionID,
                    userId: userID,
                    time: time,
                    when: weatherState) { newPackage, newIndex, isLate in
                        
                        self.currentPackage = newPackage
                        self.sunnyModules = newPackage.weatherModules.sunny
                        self.rainyModules = newPackage.weatherModules.rainy
                        
                        if self.weatherState == .sunny {
                            id = self.sunnyModules[newIndex].lockInfo.userId
                            time = self.sunnyModules[newIndex].lockInfo.timestamp
                        } else {
                            id = self.rainyModules[newIndex].lockInfo.userId
                            time = self.rainyModules[newIndex].lockInfo.timestamp
                        }
                        
                        if isLate {
                            return
                            
                        } else {
                            
                            // Dismiss loading
                            LKProgressHUD.dismiss()
                            
                            // Jump to transpVC
                            let transpVC = TranspViewController()
                            transpVC.onTranspComfirm = self.onTranspComfirm
                            transpVC.timeStamp = time
                            transpVC.actionKind = .edit(indexPath)
                            self.navigationController?.pushViewController(transpVC, animated: true)
                            
                        }
                    }
                
            } else {
                
                // Dismiss loading
                LKProgressHUD.dismiss()
                
                // Jump to transpVC
                let transpVC = TranspViewController()
                transpVC.onTranspComfirm = onTranspComfirm
                transpVC.timeStamp = time
                transpVC.actionKind = .edit(indexPath)
                self.navigationController?.pushViewController(transpVC, animated: true)
            }
        }
        
        onLocationTapped = { [weak self] cell in
            
            guard let indexPath = self?.tableView.indexPath(for: cell),
            let self = self else { return }
            
            // Show loading
            LKProgressHUD.show()
            
            if isMultiUser {
                
                var time = 0.0
                var id = ""
                if weatherState == .sunny {
                    
                    guard let rawIndex = findModuleIndex(
                        modules: sunnyModules,
                        from: indexPath) else { return }
                    
                    time = self.sunnyModules[rawIndex].lockInfo.timestamp
                    
                } else {
                    
                    guard let rawIndex = findModuleIndex(
                        modules: rainyModules,
                        from: indexPath) else { return }
                    
                    time = self.rainyModules[rawIndex].lockInfo.timestamp
                }
                
                self.firestoreManager.lockModuleWithTrans(
                    packageId: self.sessionID,
                    userId: userID,
                    time: time,
                    when: weatherState
                ) { newPackage, newIndex, isLate in
                    
                    // Dismiss loading
                    LKProgressHUD.dismiss()
                    
                    self.currentPackage = newPackage
                    self.sunnyModules = newPackage.weatherModules.sunny
                    self.rainyModules = newPackage.weatherModules.rainy
                    
                    if self.weatherState == .sunny {
                        id = self.sunnyModules[newIndex].lockInfo.userId
                        time = self.sunnyModules[newIndex].lockInfo.timestamp
                    } else {
                        id = self.rainyModules[newIndex].lockInfo.userId
                        time = self.rainyModules[newIndex].lockInfo.timestamp
                    }
                        
                    if isLate {
                        return
                        
                    } else {
                        
                        // Go to explore
                        DispatchQueue.main.async {
                            let exploreVC = ExploreSiteViewController()
                            exploreVC.onLocationComfirmMU = self.onLocationComfirmMU
                            exploreVC.actionKind = .edit(indexPath)
                            exploreVC.id = id
                            exploreVC.time = time
                            self.navigationController?.pushViewController(exploreVC, animated: true)
                        }
                    }
                }
                
            } else {
                
                // Dismiss loading
                LKProgressHUD.dismiss()
                
                // Go to explore
                let exploreVC = ExploreSiteViewController()
                exploreVC.onLocationComfirm = self.onLocationComfirm
                exploreVC.actionKind = .edit(indexPath)
                self.navigationController?.pushViewController(exploreVC, animated: true)
            }
        }
    }
}

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

import GoogleMaps
import GooglePlaces

enum WeatherState {
    case sunny
    case rainy
}

class PackageBaseViewController: UIViewController {
    
    // Session
    var documentPath = ""
    var isMultiUser = false {
        didSet {
            print("isMulti-user: \(isMultiUser)")
        }
    }
    
    // User
    var userManager = UserManager.shared
    
    var userID: String {
        return userManager.currentUser.uid
    }
    
    var userName: String {
        return userManager.currentUser.name
    }
    
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
    
    var sunnyPhotoReferences = [String: String]()
    var rainyPhotoReferences = [String: String]()
    var sunnyPhotos = [String: UIImage]()
    var rainyPhotos = [String: UIImage]()
    
    // Weather state can be switched
    var weatherState = WeatherState.sunny {
        didSet {
            
            switch weatherState {
            case .sunny:
                self.fetchPhotosHelperFunction(modules: sunnyModules)
            case .rainy:
                self.fetchPhotosHelperFunction(modules: rainyModules)
            }
            
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
    
    // View model
    var regionTags = [String]()
        
    let viewModel = CreateViewModel()
    
    // Manager
    var googlePlaceManager = GooglePlacesManager.shared
    var firestoreManager = FirestoreManager.shared
    var routeManager = RouteManager.shared
    
    // On events
    var onDelete: ((UITableViewCell) -> Void)?
    var onLocationComfirm: ( (Location, ActionKind) -> Void )?
    var onLocationComfirmMU: ( (Location, String, TimeInterval, ActionKind) -> Void )?
    var onLocationComfirmWithAddress: ( ([GMSAddressComponent]? ) -> Void )?
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switch weatherState {
        case .sunny:
            self.fetchPhotosHelperFunction(modules: sunnyModules)
        case .rainy:
            self.fetchPhotosHelperFunction(modules: rainyModules)
        }
    }
    
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
        
        // Data binding
        viewModel.sunnyModules.bind { modules in
            
            self.sunnyModules = modules
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        viewModel.rainyModules.bind { modules in
            self.rainyModules = modules
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        viewModel.currentPackage.bind { newPackage in
            if newPackage != Package() {
                
                self.sunnyModules = newPackage.weatherModules.sunny
                self.rainyModules = newPackage.weatherModules.rainy
                self.currentPackage = newPackage
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        
        viewModel.regionTags.bind { tags in
            self.regionTags = tags
        }
        
        viewModel.sunnyPhotos.bind { photos in
            self.sunnyPhotos = photos
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        viewModel.rainyPhotos.bind { photos in
            self.rainyPhotos = photos
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        // Inject initial data
        sunnyModules = currentPackage.weatherModules.sunny
        rainyModules = currentPackage.weatherModules.rainy
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.setEditing(false, animated: false)
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
        let photos = weatherState == .sunny ? sunnyPhotos : rainyPhotos
        
        guard let rawIndex = viewModel.findModuleIndex(modules: module, from: indexPath) else {return UITableViewCell()}
        let travelTime = module[rawIndex].transportation.travelTime
        let iconName = module[rawIndex].transportation.transpIcon
        let locationTitle = "\(module[rawIndex].location.shortName)"
        let id = module[rawIndex].location.identifier
        
        // Display user id and name
        let cellUserId = module[rawIndex].lockInfo.userId
        let cellUserName = module[rawIndex].lockInfo.userName
        cell.userIdLabel.text = cellUserId != "" ? cellUserName: ""
        
        // Location title
        cell.siteTitle.text = locationTitle
        
        // Transp Icon
        let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
        cell.transpIcon.image = UIImage(systemName: iconName, withConfiguration: config)
        cell.transpIcon.contentMode = .scaleAspectFit
        cell.travelTimeLabel.text = formatTimeInterval(travelTime)
        
        // Find last cell, and handel visibility
        viewModel.configureLastCell(
            cell: cell,
            tableView: tableView,
            indexPath: indexPath)
        
        // Configure cell appearance
        viewModel.configureCellInMUState(
            cell: cell,
            cellUserId: cellUserId,
            userId: userID,
            onLocationTapped: self.onLocationTapped,
            onTranspTapped: self.onTranspTapped)
        
        // Set BG photos
        if photos != [String: UIImage]() {
            cell.bgImageView.image = photos[id]
            cell.bgImageView.contentMode = .scaleAspectFill
        }
        
        // Set rating
        if cell.siteTitle.text != "None" {
            cell.googleRating.text = viewModel.ratingForIndexPath(indexPath: indexPath)
        } else {
            cell.googleRating.text = String(repeating: "☆", count: 5)
            viewModel.configureCellInWeatherState(cell: cell, state: weatherState)
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
            
//            let rawIndex = viewModel.findModuleIndex(modules: self.sunnyModules, from: indexPath)
//            let id = self.sunnyModules[rawIndex ?? 0].lockInfo.userId
//            if id != "" && id != "none" && id != "None" && id != userID {
//                return
//            }
            
            // Perform deletion of the item from your data source
//            if self.weatherState == .sunny {
            
            currentPackage.weatherModules.sunny = sunnyModules
            currentPackage.weatherModules.rainy = rainyModules
            
                viewModel.deleteModule(
                    docPath: documentPath,
                    currentPackage: currentPackage,
                    indexPath: indexPath,
                    userID: userID,
                    weatherState: weatherState)
                
//            } else {
                
//                let rawIndexForModule = self.viewModel.findModuleIndex(
//                    modules: self.rainyModules,
//                    from: indexPath)
//                let time = self.rainyModules[rawIndexForModule ?? 0].lockInfo.timestamp
//                
//                // Is in multi-user mode or not
//                if self.isMultiUser {
//                    
//                    // Delete first
//                    self.rainyModules.remove(at: rawIndexForModule ?? 0)
//                    
//                    DispatchQueue.main.async {
//                        self.tableView.reloadData()
//                    }
//                    
//                    self.firestoreManager.deleteModuleWithTrans(
//                        
//                        docPath: self.documentPath,
//                        time: time,
//                        targetIndex: rawIndexForModule ?? 0,
//                        with: self.currentPackage,
//                        when: .rainy
//                    ) { newPackage in
//                        self.currentPackage = newPackage
//                        self.sunnyModules = newPackage.weatherModules.sunny
//                    }
//                    
//                } else {
//                    
//                    self.rainyModules.remove(at: rawIndexForModule ?? 0)
//                }
//            }
//                
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
        }
    }

    // Can move row at
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        let rawIndex = viewModel.findModuleIndex(modules: self.sunnyModules, from: indexPath)
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
        
        self.bgImageView.contentMode = .scaleAspectFill
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
    
    // Logic to swap module
    func movePackage(from source: IndexPath, to destination: IndexPath) {
        
        if weatherState == .sunny {
            
            // First find out the "raw" index of the module
            guard let sourceRowIndex = viewModel.findModuleIndex(
                modules: sunnyModules,
                from: source) else {return}
            guard let destRowIndex = viewModel.findModuleIndex(
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
                    docPath: documentPath,
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
            guard let sourceRowIndex = viewModel.findModuleIndex(
                modules: rainyModules,
                from: source) else {return}
            guard let destRowIndex = viewModel.findModuleIndex(
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
                    docPath: documentPath,
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
    
    // Helper function
    func fetchPhotosHelperFunction(modules: [PackageModule]) {
        
        var refs = [String: String]()
        
        switch self.weatherState {
        case .sunny:
            self.sunnyPhotoReferences = self.viewModel.mapToDictionary(module: modules)
            refs = self.sunnyPhotoReferences
        case .rainy:
            self.rainyPhotoReferences = self.viewModel.mapToDictionary(module: modules)
            refs = self.rainyPhotoReferences
        }
        
        self.viewModel.fetchSitePhotos(
            weatherState: self.weatherState,
            photoReferences: refs)
    }
    
    // MARK: - Setup onEvents -
    func setupOnComfirm() {
        
        onLocationComfirmMU = { [weak self] location, id, time, actionKind in
            
            guard let self = self else { return }
            
            switch actionKind {
            case .add( let section ):
                
                if self.weatherState == .sunny {
                    
                    let module = PackageModule(
                        location: location,
                        transportation: Transportation(
                            transpIcon: "plus.viewfinder",
                            travelTime: 0.0),
                        day: section)
                    
                    self.sunnyModules.append(module)
                    self.afterAppendComfirmed?(module)
                    
                    fetchPhotosHelperFunction(modules: sunnyModules)
                    
                } else {
                    
                    let module = PackageModule(
                        location: location,
                        transportation: Transportation(
                            transpIcon: "plus.viewfinder",
                            travelTime: 0.0),
                        day: section)
                    
                    self.rainyModules.append(module)
                    self.afterAppendComfirmed?(module)
                    
                    fetchPhotosHelperFunction(modules: rainyModules)
                }
                
            case .edit(let index):
                print("index with no use \(index)")
                if self.weatherState == .sunny {
                    
                    if let rawIndex = self.sunnyModules.firstIndex(where: {
                        if $0.lockInfo.userId == id && $0.lockInfo.timestamp == time {
                            return true
                        } else { return false }
                        
                    }) {
                        self.sunnyModules[rawIndex].location = location
                        self.afterEditComfirmed?(rawIndex, time)
                        
                        fetchPhotosHelperFunction(modules: sunnyModules)
                    }
                    
                } else {
                    
                    if let rawIndex = self.rainyModules.firstIndex(where: {
                        if $0.lockInfo.userId == id && $0.lockInfo.timestamp == time {
                            return true
                        } else { return false }
                        
                    }) {
                        self.rainyModules[rawIndex].location = location
                        self.afterEditComfirmed?(rawIndex, time)
                        
                        fetchPhotosHelperFunction(modules: rainyModules)
                    }
                }
            }
        }
        
        onLocationComfirm = { [weak self] location, action in
            
            guard let self = self else { return }
            
            switch action {
            case .add(let section):
                
                let module = PackageModule(
                    location: location,
                    transportation: Transportation(
                        transpIcon: "plus.viewfinder",
                        travelTime: 0.0),
                    day: section)
                
                if self.weatherState == .sunny {
                    self.sunnyModules.append(module)
                    fetchPhotosHelperFunction(modules: sunnyModules)
                    
                } else {
                    self.rainyModules.append(module)
                    fetchPhotosHelperFunction(modules: rainyModules)
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            case .edit(let targetIndex):

                if self.weatherState == .sunny {
                    if let index = self.viewModel.findModuleIndex(
                        modules: self.sunnyModules,
                        from: targetIndex) {
                        self.sunnyModules[index].location = location
                    }
                    fetchPhotosHelperFunction(modules: sunnyModules)
                    
                } else {
                    if let index = self.viewModel.findModuleIndex(
                        modules: self.rainyModules,
                        from: targetIndex) {
                        self.rainyModules[index].location = location
                    }
                    
                    fetchPhotosHelperFunction(modules: rainyModules)
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
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
                    
                    let rawDestIndexPath = viewModel.findNextIndexPath(
                        currentIndex: targetIndex,
                        in: self.tableView)
                    
                    sunnySourceRawIndex = viewModel.findModuleIndex(
                        modules: self.sunnyModules,
                        from: targetIndex) ?? 0
                    
                    sunnyDestRawIndex = viewModel.findModuleIndex(
                        modules: self.sunnyModules,
                        from: rawDestIndexPath ?? IndexPath()) ?? 0
                    
                    sourceCoordDic = self.sunnyModules[sunnySourceRawIndex].location.coordinate
                    destCoordDic = self.sunnyModules[sunnyDestRawIndex].location.coordinate
                    
                } else {
                    
                    let rawDestIndexPath = viewModel.findNextIndexPath(
                        currentIndex: targetIndex,
                        in: self.tableView)
                    
                    rainySourceRawIndex = viewModel.findModuleIndex(
                        modules: self.rainyModules,
                        from: targetIndex) ?? 0
                    
                    rainyDestRawIndex = viewModel.findModuleIndex(
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
                
                // Breaking system
                if sourceCoord.latitude == 0 || destCoord.latitude == 0 {
                    LKProgressHUD.dismiss()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        LKProgressHUD.showFailure(text: "Not enough data provided")
                    }
                    
                    return
                }
                
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
            exploreVC.onLocationComfirmWithAddress = self.onLocationComfirmWithAddress
            self.navigationController?.pushViewController(exploreVC, animated: true)
            
        }
        
        onTranspTapped = { [weak self] cell in
            guard let indexPath = self?.tableView.indexPath(for: cell),
            let self = self else { return }
            
            // Show loading
            LKProgressHUD.show()
            
            var rawIndex = 0
            var time = 0.0
            // var id = ""
            
            // Find time first
            if weatherState == .sunny {
                rawIndex = viewModel.findModuleIndex(modules: sunnyModules, from: indexPath) ?? 0
                time = self.sunnyModules[rawIndex].lockInfo.timestamp
            } else {
                rawIndex = viewModel.findModuleIndex(modules: rainyModules, from: indexPath) ?? 0
                time = self.rainyModules[rawIndex].lockInfo.timestamp
            }
            
            if isMultiUser {
                self.firestoreManager.lockModuleWithTrans(
                    docPath: self.documentPath,
                    userId: userID,
                    userName: userName,
                    time: time,
                    when: weatherState) { newPackage, newIndex, isLate in
                        
                        self.currentPackage = newPackage
                        self.sunnyModules = newPackage.weatherModules.sunny
                        self.rainyModules = newPackage.weatherModules.rainy
                        
                        if self.weatherState == .sunny {
                            // id = self.sunnyModules[newIndex].lockInfo.userId
                            time = self.sunnyModules[newIndex].lockInfo.timestamp
                        } else {
                            // id = self.rainyModules[newIndex].lockInfo.userId
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
                    
                    guard let rawIndex = viewModel.findModuleIndex(
                        modules: sunnyModules,
                        from: indexPath) else { return }
                    
                    time = self.sunnyModules[rawIndex].lockInfo.timestamp
                    
                } else {
                    
                    guard let rawIndex = viewModel.findModuleIndex(
                        modules: rainyModules,
                        from: indexPath) else { return }
                    
                    time = self.rainyModules[rawIndex].lockInfo.timestamp
                }
                
                self.firestoreManager.lockModuleWithTrans(
                    docPath: self.documentPath,
                    userId: userID,
                    userName: userName,
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
                            exploreVC.onLocationComfirmWithAddress = self.onLocationComfirmWithAddress
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
                exploreVC.onLocationComfirmWithAddress = self.onLocationComfirmWithAddress
                exploreVC.actionKind = .edit(indexPath)
                self.navigationController?.pushViewController(exploreVC, animated: true)
            }
        }
    }
}

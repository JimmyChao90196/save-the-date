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
    
    // User data
    var userManager = UserManager.shared
    var userID: String { return userManager.currentUser.uid }
    var userName: String { return userManager.currentUser.name }
    
    var regionTags = [String]()
    
    // Current package
    var currentPackage = Package()
    var sunnyModules = [PackageModule]() {
        didSet {
            DispatchQueue.main.async {
                self.changeBGImage()
            }
        }
    }
    var rainyModules = [PackageModule]() {
        didSet {
            DispatchQueue.main.async {
                self.changeBGImage()
            }
        }
    }
    
    var sunnyPhotoReferences = [String: String]()
    var rainyPhotoReferences = [String: String]()
    var sunnyPhotos = [String: UIImage]()
    var rainyPhotos = [String: UIImage]()
    
    // Weather state can be switched
    var weatherState = WeatherState.sunny {
        didSet {
            
            self.currentPackage.weatherModules.sunny = self.sunnyModules
            self.currentPackage.weatherModules.rainy = self.rainyModules
            self.viewModel.fetchPhotosHelperFunction(when: weatherState, with: self.currentPackage)
            
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
    
    // MARK: - View will appear & view did load -
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.fetchPhotosHelperFunction( when: weatherState, with: self.currentPackage)
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
        
        // Data binding for sunny modules
        viewModel.sunnyModules.bind { modules in
            
            self.sunnyModules = modules
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        // Data binding for rainy modules
        viewModel.rainyModules.bind { modules in
            self.rainyModules = modules
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        // Data binding for overall package
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
        
        // Data binding for regionTags
        viewModel.regionTags.bind { tags in
            self.regionTags = tags
        }
        
        // Data binding for sunnyPhotos
        viewModel.sunnyPhotos.bind { photos in
            self.sunnyPhotos = photos
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        // Data binding for rainyPhotos
        viewModel.rainyPhotos.bind { photos in
            self.rainyPhotos = photos
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        // Inject initial data
        sunnyModules = currentPackage.weatherModules.sunny
        rainyModules = currentPackage.weatherModules.rainy
        
        // Configure tableView
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
            if photos[id] == nil {
                cell.bgImageView.image = UIImage(resource: .site04)
            } else {
                cell.bgImageView.image = photos[id]
            }
            
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
            
            currentPackage.weatherModules.sunny = sunnyModules
            currentPackage.weatherModules.rainy = rainyModules
            
                viewModel.deleteModule(
                    docPath: documentPath,
                    currentPackage: currentPackage,
                    indexPath: indexPath,
                    userID: userID,
                    weatherState: weatherState)
        }
    }

    // Can move row at
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        
        var id = ""
        var rawIndex = 0
        
        switch weatherState {
        case .sunny:
            rawIndex = viewModel.findModuleIndex(modules: self.sunnyModules, from: indexPath) ?? 0
            id = self.sunnyModules[rawIndex].lockInfo.userId
        case .rainy:
            rawIndex = viewModel.findModuleIndex(modules: self.rainyModules, from: indexPath) ?? 0
            id = self.rainyModules[rawIndex].lockInfo.userId
        }
        
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

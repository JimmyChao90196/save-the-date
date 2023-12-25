//
//  CreateVM.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/30.
//

import Foundation
import GoogleMaps
import GooglePlaces
import CoreLocation

// This is a cell configuration protocol
protocol CellClaimingProtocol {
    var userIdIsHidden: Bool { get }
    var userIdBackgroundColor: UIColor { get }
    var userIdTextColor: UIColor { get }
    
    var locationViewBoarderColor: UIColor { get }
    var transpIconTintColor: UIColor { get }
    var travelLabelTextColor: UIColor { get }
    
    var siteTitletextColor: UIColor { get }
    var arrivedTimeLabelTextColor: UIColor { get }
    
    var contentViewBoarderColor: UIColor { get }
}

class CreateViewModel {
    
    let googlePlaceManger = GooglePlacesManager.shared
    let firestoreManager = FirestoreManager.shared
    
    let regionTags = Box<[String]>([])
    var sunnyPhotos = Box<[String: UIImage]>([:])
    var rainyPhotos = Box<[String: UIImage]>([:])
    var sunnyPhotoReferences = [String: String]()
    var rainyPhotoReferences = [String: String]()
    
    var currentPackage = Box<Package>(Package())
    var sunnyModules = Box<[PackageModule]>([])
    var rainyModules = Box<[PackageModule]>([])
    
    var coords = Box<[CLLocationCoordinate2D]>([
    CLLocationCoordinate2D(latitude: 0, longitude: 0),
    CLLocationCoordinate2D(latitude: 0, longitude: 0)
    ])
    
    // MARK: - Configure cell -
    // Configure last cell
    func configureLastCell(
        cell: UITableViewCell,
        tableView: UITableView,
        indexPath: IndexPath) {
            
            guard let cell = cell as? ModuleTableViewCell else { return }
            
            let totalSections = tableView.numberOfSections
            let totalRowsInLastSection = tableView.numberOfRows(inSection: totalSections - 1)
            let isLastCell = indexPath.section == totalSections - 1 && indexPath.row == totalRowsInLastSection - 1
            
            if isLastCell {
                cell.onTranspTapped = nil
                cell.transpView.isHidden = true
            } else {
                cell.transpView.isHidden = false
            }
        }
    
    // Configure cell with different weather state
    func configureCellInWeatherState(
        cell: UITableViewCell,
        state: WeatherState) {
            guard let cell = cell as? ModuleTableViewCell else { return }
            
            switch state {
            case .sunny:
                cell.bgImageView.image = UIImage(resource: .site04)
                cell.bgImageView.contentMode = .scaleAspectFit
            case .rainy:
                cell.bgImageView.image = UIImage(resource: .site05)
                cell.bgImageView.contentMode = .scaleAspectFit
            }
        }
    
    // Configure cell with different MUState
    func configureCellInMUState(
        cell: UITableViewCell,
        cellUserId: String,
        userId: String,
        onLocationTapped: ((UITableViewCell) -> Void)?,
        onTranspTapped: ((UITableViewCell) -> Void)?
    ) {
        guard let cell = cell as? ModuleTableViewCell else { return }
        
        if cellUserId == userId {
            
            cell.onLocationTapped = onLocationTapped
            cell.onTranspTapped = onTranspTapped
            configureCellAppearance(cell: cell, config: CellClaimedByUser())
            
        } else if cellUserId == "" {
            
            cell.onLocationTapped = onLocationTapped
            cell.onTranspTapped = onTranspTapped
            configureCellAppearance(cell: cell, config: Cellunclaimed())
            
        } else {
            
            cell.onLocationTapped = nil
            cell.onTranspTapped = nil
            configureCellAppearance(cell: cell, config: CellClaimedByOthers())
        }
    }
    
    func configureCellAppearance(
        cell: UITableViewCell,
        config: CellClaimingProtocol) {
            
            if let cell = cell as? ModuleTableViewCell {
                cell.userIdLabel.isHidden = config.userIdIsHidden
                cell.userIdLabel.setbackgroundColor(config.userIdBackgroundColor)
                cell.userIdLabel.setTextColor(config.userIdTextColor)
                cell.locationView.setBoarderColor(config.locationViewBoarderColor)
                cell.transpIcon.tintColor = config.transpIconTintColor
                cell.travelTimeLabel.setTextColor(config.travelLabelTextColor)
                cell.siteTitle.setTextColor(config.siteTitletextColor)
                cell.googleRating.setTextColor(config.arrivedTimeLabelTextColor)
                cell.contentView.setBoarderColor(config.contentViewBoarderColor)
            }
        }
    
    // Fake rating system.
    func ratingForIndexPath(indexPath: IndexPath, minimumRating: Double = 3.0) -> String {
        
        // Use the hash value of the index path as a seed substitute
        let seed = indexPath.hashValue
        var rng = SeededGenerator(seed: seed)
        
        // Ensure minimumRating is within the valid range (0 to 5)
        let clampedMinimumRating = min(max(minimumRating, 0.0), 5.0)
        
        // Generate a random rating between clampedMinimumRating and 5
        let maxRating = 5
        let rating = max(Double.random(in: 0...5, using: &rng), clampedMinimumRating)
        let fullStarCount = Int(rating)
        let fullStarString = String(repeating: "★", count: fullStarCount)
        let emptyStarCount = maxRating - fullStarCount
        let emptyStarString = String(repeating: "☆", count: emptyStarCount)
        return fullStarString + emptyStarString
    }
    
    // Custom random number generator using a hash value as a seed
    struct SeededGenerator: RandomNumberGenerator {
        private var state: UInt64
        
        init(seed: Int) {
            state = UInt64(abs(seed))
        }
        
        mutating func next() -> UInt64 {
            state = 6364136223846793005 &* state &+ 1
            return state
        }
    }
    
    // MARK: - Find index function -
    
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
    
    // Find next indexPath
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
            return nil
        }
    
    // MARK: - delete function -
    func deleteModule(
        docPath: String?,
        currentPackage: Package,
        indexPath: IndexPath,
        userID: String,
        weatherState: WeatherState) {
            
            var modules = weatherState == .sunny ?
            currentPackage.weatherModules.sunny:
            currentPackage.weatherModules.rainy
            
            // Return if the cell is claimed.
            let rawIndex = findModuleIndex(modules: modules, from: indexPath)
            let id = modules[rawIndex ?? 0].lockInfo.userId
            if id != "" && id != "none" && id != "None" && id != userID { return }
            let time = modules[rawIndex ?? 0].lockInfo.timestamp
            
            switch weatherState {
            case .sunny:
                modules.remove(at: rawIndex ?? 0)
                self.sunnyModules.value = modules
            case .rainy:
                modules.remove(at: rawIndex ?? 0)
                self.rainyModules.value = modules
            }
            
            if docPath != "" {
                
                firestoreManager.deleteModuleWithTrans(
                    docPath: docPath ?? "",
                    time: time,
                    targetIndex: rawIndex ?? 0,
                    with: currentPackage,
                    when: weatherState) { newPackage in
                        self.currentPackage.value = newPackage
                    }
            }
        }
    
    // MARK: - Move module function -
    func swapModule(
        docPath: String?,
        currentPackage: Package,
        source: IndexPath,
        dest: IndexPath,
        weatherState: WeatherState) {
            
            var modules = weatherState == .sunny ?
            currentPackage.weatherModules.sunny:
            currentPackage.weatherModules.rainy
            
            // First find out the "raw" index of the module
            guard let sourceRowIndex = findModuleIndex(
                modules: modules,
                from: source) else { return }
            guard let destRowIndex = findModuleIndex(
                modules: modules,
                from: dest) else { return }
            
            switch weatherState {
            case .sunny:
                modules.swapAt(sourceRowIndex, destRowIndex)
                self.sunnyModules.value = modules
            case .rainy:
                modules.swapAt(sourceRowIndex, destRowIndex)
                self.rainyModules.value = modules
            }
            
            if docPath != "" {
                firestoreManager.swapModulesWithTrans(
                    docPath: docPath ?? "",
                    sourceIndex: sourceRowIndex,
                    destIndex: destRowIndex,
                    with: currentPackage,
                    when: weatherState) { newPackage in
                        self.currentPackage.value = newPackage
                    }
            }
        }
    
    // MARK: - Additional functions -
    
    // Check if the package is empty
    func shouldPublish(
        sunnyModule: [PackageModule],
        rainyModule: [PackageModule]) -> Bool {
            
            if sunnyModule == [] && rainyModule == [] {
                return false
            } else {
                return true
            }
        }
    
    // ParseAddress
    func parseAddress(
        from addressComponents: [GMSAddressComponent]?,
        currentTags: [String]
    ) {
        var city: String?
        var district: String?
        var country: String?
        
        guard let addressComponents else { return }
        
        for component in addressComponents {
            // Check if the component is a city
            if component.types.contains("administrative_area_level_1") {
                city = component.name.replacingOccurrences(of: " City", with: "")
                city = city?.replacingOccurrences(of: " Country", with: "")
                city = city?.replacingOccurrences(of: " County", with: "")
                city = city?.replacingOccurrences(of: " Township", with: "")
            }
            // Check if the component is a district
            else if component.types.contains("administrative_area_level_2") {
                district = component.name.replacingOccurrences(of: " City", with: "")
                district = district?.replacingOccurrences(of: " Country", with: "")
                district = district?.replacingOccurrences(of: " County", with: "")
                district = district?.replacingOccurrences(of: " Township", with: "")
                
            } else if component.types.contains("country") {
                // This is the country
                country = component.name.replacingOccurrences(of: " City", with: "")
                country = country?.replacingOccurrences(of: " Country", with: "")
                country = country?.replacingOccurrences(of: " County", with: "")
                country = country?.replacingOccurrences(of: " Township", with: "")
            }
        }
        
        // Append to region
        var tagSet = Set(currentTags)
        
        if let city, let district, let country {
            
            tagSet.insert(city)
            tagSet.insert(district)
            tagSet.insert(country)
        }
        
        regionTags.value = Array(tagSet)
    }
    
    // MARK: - Fetch photos -
    func mapToDictionary(module: [PackageModule]) -> [String: String] {
        
        var dict = [String: String]()
        
        for item in module {
            dict[item.location.identifier] = item.location.photoReference
        }
        
        return dict
    }
    
    func fetchSitePhotos(
        weatherState: WeatherState,
        photoReferences: [String: String]?) {
            
            guard let photoReferences = photoReferences else { return }
            
            googlePlaceManger.fetchPhotos(
                photoReferences: photoReferences) { result in
                    switch result {
                    case .success(let success):
                        switch weatherState {
                        case .sunny:
                            self.sunnyPhotos.value = success
                        case .rainy:
                            self.rainyPhotos.value = success
                        }
                        
                    case .failure(let failure):
                        print("faild fetching photos: \(failure)")
                    }
                }
        }
    
    func fetchPhotosHelperFunction(when weatherState: WeatherState, with currentPackage: Package) {
        
        var refs = [String: String]()
        
        let modules = weatherState == .sunny ?
        currentPackage.weatherModules.sunny:
        currentPackage.weatherModules.rainy
        
        switch weatherState {
        case .sunny:
            self.sunnyPhotoReferences = mapToDictionary(module: modules)
            refs = self.sunnyPhotoReferences
        case .rainy:
            self.rainyPhotoReferences = mapToDictionary(module: modules)
            refs = self.rainyPhotoReferences
        }
        
        fetchSitePhotos(
            weatherState: weatherState,
            photoReferences: refs)
    }
}

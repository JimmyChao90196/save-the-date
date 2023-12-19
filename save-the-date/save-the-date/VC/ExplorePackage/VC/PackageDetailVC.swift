//
//  PackageDetailVC.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/18.
//

import Foundation
import UIKit
import SnapKit
import Hover
import FirebaseFirestoreSwift

enum EnterFrom {
    case profile
    case explore
}

class PackageDetailViewController: PackageBaseViewController {
    
    // User manager
    let userManger = UserManager.shared
    
    // Is editing
    var isInEditMode = false
    var shouldEdit = false
    
    // Hover button
    var hoverButton = HoverView()
    var enterFrom = EnterFrom.profile
    
    // View model
    var count = 0
    let packageDetailVM = PackageDetailViewModel()
    
    // Nav item
    lazy var moreButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis"),
            style: .plain,
            target: self,
            action: #selector(moreButtonPressed))
        
        return button
    }()
    
    lazy var editButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(systemName: "slider.horizontal.3"),
            style: .plain,
            target: self,
            action: #selector(editButtonPressed))
        
        return button
    }()
    
    lazy var doneButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            title: "Done",
            style: .plain,
            target: self,
            action: #selector(editButtonPressed))
        
        return button
    }()
    
    // Add new day button
    lazy var addNewDayButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 85, height: 30))
        // Your logic to customize the button
        button.backgroundColor = .blue
        button.setTitle("New Day", for: .normal)
        button.titleLabel?.setFont(UIFont.systemFont(ofSize: 16, weight: .medium))
        button.setBoarderColor(.hexToUIColor(hex: "#3F3A3A"))
            .setbackgroundColor(.hexToUIColor(hex: "#87D6DD"))
            .setCornerRadius(5)
            .setBoarderWidth(2.5)
        
        // Adding an action
        button.addTarget(
            self,
            action: #selector(addNewDayPressed),
            for: .touchUpInside)
        
        return button
    }()
    
    override func setup() {
        super.setup()
        
        // MARK: - Configure header view -
        let headerView = CustomHeaderView()
        
        headerView.frame = CGRect(
            x: 0,
            y: 0,
            width: tableView.bounds.width,
            height: 265)
        
        let testImages = [
            UIImage(resource: .placeholder01),
            UIImage(resource: .placeholder02),
            UIImage(resource: .placeholder03)
        ]
        
        // Setup title
        headerView.packageTitle.text = self.currentPackage.info.title
        
        // Setup images
        packageDetailVM.fetchAuthorImages(ids: self.currentPackage.info.authorId)
        headerView.createAuthorImageViews(with: testImages)
        
        // Setup tags
        let regionTags = self.currentPackage.regionTags
        headerView.setupScrollView()
        headerView.createTagLabels(with: regionTags)
        
        tableView.tableHeaderView = headerView
        
        // Configure nav title
        self.title = "Package Detail"
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        // Configure nav button
        let addBarButton = UIBarButtonItem(customView: addNewDayButton)
        self.navigationItem.rightBarButtonItems = [addBarButton]
        
        tableView.setEditing(false, animated: false)
        tableView.backgroundColor = .clear
        tableView.visibleCells.forEach { cell in
            guard let cell = cell as? ModuleTableViewCell else { return }
            cell.locationView.gestureRecognizers?.forEach { $0.isEnabled = false }
            cell.transpIcon.gestureRecognizers?.forEach { $0.isEnabled = false }
        }
        
        // Hover button
        let config = HoverConfiguration(
            image: UIImage(systemName: "gear"),
            color: .color(.hexToUIColor(hex: "#FF4E4E")),
            size: 50,
            imageSizeRatio: 0.7
        )
        
        let items = [
            HoverItem(
                title: "Enter editing mode",
                image: UIImage(systemName: "square.and.pencil"),
                onTap: { self.enterEditModePressed() }),
            HoverItem(
                title: "Save",
                image: UIImage(systemName: "square.and.arrow.up"),
                onTap: { self.saveButtonPressed() })
        ]
        
        hoverButton = HoverView(with: config, items: items)
        hoverButton.tintColor = .white

        packageDetailVM.shouldEdit(
            authorIds: currentPackage.info.authorId,
            from: enterFrom)
        
        view.addSubviews([hoverButton])
        
        hoverButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // Setup onConfirm event
        onLocationComfirmWithAddress = { components in
            self.viewModel.parseAddress(from: components, currentTags: self.regionTags)
        }
        
        // Data binding
        packageDetailVM.shouldEdit.bind { value in
            self.shouldEdit = value
            self.hoverButton.isHidden = !self.shouldEdit
        }
        
        packageDetailVM.authorImages.bind { fetchedImages in
            DispatchQueue.main.async {
                headerView.createAuthorImageViews(with: fetchedImages)
            }
        }
        
        packageDetailVM.isInEditMode.bind { [weak self] isInEditMode in
            guard let self = self else { return }
            
                self.isInEditMode = isInEditMode
                
            switch isInEditMode {
            case true:
                let addBarButton = UIBarButtonItem(customView: addNewDayButton)
                navigationItem.rightBarButtonItems = [addBarButton, editButton]
                self.title = "Edit Package"
                
            case false:
                
                switch self.shouldEdit {
                case true:  navigationItem.rightBarButtonItems = []
                case false: navigationItem.rightBarButtonItems = [moreButton]
                }
                
                self.title = "Package Detail"
            }
            
            // Reload table view at the end
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
// MARK: - Additional function
    
    func submitHelperFunction(requestType: RequestType) {
        
        // Submitting report
        self.packageDetailVM.submitRequest(
            targetDocPath: self.currentPackage.docPath,
            requestType: requestType) {
                
                // Present alert
                self.presentSimpleAlert(
                    title: "Success",
                    message: "Successfully submitted the \(requestType.rawValue) reqeust",
                    buttonText: "Okay")
            }
    }
    
    @objc func moreButtonPressed() {
        let options = ["Report"]
        presentSimpleAlert(
            by: options,
            title: "Perform action to this package",
            message: "In appropreate content?",
            buttonText: "Okay") { [weak self] alertAction in
                let alertTitle = alertAction.title
                switch alertTitle {
                    
                case "Report":
                    
                    self?.submitHelperFunction(requestType: .report)
                    
                case "Restrict":
                    
                    self?.submitHelperFunction(requestType: .restrict)
                    
                case "Block":
                    
                    self?.submitHelperFunction(requestType: .block)
                    
                default: print("Default")
                    
                }
            }
    }
    
    func enterEditModePressed() {
        packageDetailVM.enterPackageMode()
    }
    
    func saveButtonPressed() {
        self.currentPackage.weatherModules.sunny = self.sunnyModules
        self.currentPackage.weatherModules.rainy = self.rainyModules
        self.currentPackage.regionTags = self.regionTags
        packageDetailVM.saveRevicedPackage(package: self.currentPackage)
    }
    
    // Edit bar button pressed
    @objc func editButtonPressed() {
        
        if shouldEdit {
            shouldEdit = false
            tableView.setEditing(false, animated: true)
            
            let addBarButton = UIBarButtonItem(customView: addNewDayButton)
            navigationItem.rightBarButtonItems = [addBarButton, editButton]
            
        } else {
            shouldEdit = true
            tableView.setEditing(true, animated: true)
            
            let addBarButton = UIBarButtonItem(customView: addNewDayButton)
            navigationItem.rightBarButtonItems = [addBarButton, doneButton]
        }
    }
    
    // Add empty pressed
    @objc func addNewDayPressed() {
        switch weatherState {
        case .sunny:
            
            let uniqueSet = Set(sunnyModules.compactMap { $0.day })
            let module = PackageModule(day: uniqueSet.count)
            self.sunnyModules.append(module)
            
            if isMultiUser {
                firestoreManager.appendModuleWithTrans(
                    docPath: documentPath,
                    userId: userID,
                    isNewDay: true,
                    when: weatherState,
                    with: module)
            }
            
        case .rainy:
            
            let uniqueSet = Set(rainyModules.compactMap { $0.day })
            let module = PackageModule(day: uniqueSet.count)
            self.rainyModules.append(module)
            
            if isMultiUser {
                firestoreManager.appendModuleWithTrans(
                    docPath: documentPath,
                    userId: userID,
                    isNewDay: true,
                    when: weatherState,
                    with: module)
            }
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

// MARK: - TableView delegate
extension PackageDetailViewController {
    
    // Cell for row at
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            guard let cell = cell as? ModuleTableViewCell else { return UITableViewCell()}
            
            switch isInEditMode {
            case true:
                
                cell.locationView.gestureRecognizers?.forEach { $0.isEnabled = true }
                cell.transpView.gestureRecognizers?.forEach { $0.isEnabled = true }
                
            case false:
                
                cell.locationView.gestureRecognizers?.forEach { $0.isEnabled = false }
                cell.transpView.gestureRecognizers?.forEach { $0.isEnabled = false }
            }
            
            return cell
        }
    
    // Header
    override func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int) -> UIView? {
            
            switch isInEditMode {
            case true:
                guard let headerView = tableView.dequeueReusableHeaderFooterView(
                    withIdentifier: DayHeaderView.reuseIdentifier) as? DayHeaderView else { return UIView()}
                
                headerView.section = section
                headerView.onAddModulePressed = self.onAddModulePressed
                headerView.setDay(section)
                headerView.addModuleButton.isHidden = false
                return headerView
                
            case false:
                
                guard let headerView = tableView.dequeueReusableHeaderFooterView(
                    withIdentifier: DayHeaderView.reuseIdentifier) as? DayHeaderView else { return UIView()}
                
                headerView.section = section
                headerView.setDay(section)
                headerView.addModuleButton.isHidden = true
                return headerView
            }
        }
    
    // Can move row at
    override func tableView(
        _ tableView: UITableView,
        canMoveRowAt indexPath: IndexPath) -> Bool {
            switch isInEditMode {
            case true:
                return super.tableView(tableView, canMoveRowAt: indexPath)
                
            case false:
                return false
            }
        }
    
    override func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath) {
            
            switch isInEditMode {
            case true:
                super.tableView(tableView, commit: editingStyle, forRowAt: indexPath)
                
            case false:
                print("Do nothing")
            }
        }
    
    func tableView(
        _ tableView: UITableView,
        editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
            switch isInEditMode {
            case true: return .delete
                
            case false: return .none
            }
        }
}

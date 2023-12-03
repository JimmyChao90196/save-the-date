//
//  RequestViewController.swift
//  FireBaseGroup2_iOS
//
//  Created by JimmyChao on 2023/10/24.
//

import UIKit
import Foundation

import SnapKit
import CoreLocation

import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseCore

import GoogleMaps
import GooglePlaces

import Hover

class CreatePackageViewController: PackageBaseViewController {
    
    var hoverButton = HoverView()
    
    // Nav item
    var shouldEdit = false
    lazy var editButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(systemName: "slider.horizontal.3"),
            style: .plain,
            target: self,
            action: #selector(editButtonPressed))
        
        return button
    }()
    
    lazy var saveButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            title: "Save",
            style: .plain,
            target: self,
            action: #selector(editButtonPressed))
        
        return button
    }()
   
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
    
    // MARK: - ViewWillAppear -
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print(self.regionTags)
        tableView.reloadData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButton
    }
    
    // MARK: - Basic function -
    
    override func setup() {
        super.setup()
        
        tableView.backgroundColor = .clear

        let rightBarButton = UIBarButtonItem(customView: addNewDayButton)
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        // On comfirm
        onLocationComfirmWithAddress = { components in
            self.viewModel.parseAddress(from: components, currentTags: self.regionTags)
        }
        
        // Setup hover
        setupHover()
    }
    
    // MARK: - Setup hover -
    func setupHover() {
        // Hover button
        let config = HoverConfiguration(
            image: UIImage(systemName: "square.and.arrow.up"),
            color: .color(.hexToUIColor(hex: "#FF4E4E")),
            size: 50,
            imageSizeRatio: 0.7
        )
        
        let items = [
            HoverItem(
                title: "Enter multi-user session",
                image: UIImage(systemName: "person.2.fill"),
                onTap: { self.enterMultiUserPressed() }),
            
            HoverItem(
                title: "Create multi-user session",
                image: UIImage(systemName: "person.fill.badge.plus"),
                onTap: { self.createSessionPressed() }),
            
            HoverItem(
                title: "Publish",
                image: UIImage(systemName: "square.and.arrow.up"),
                onTap: { self.publishButtonPressed() })
        ]
        
        hoverButton = HoverView(with: config, items: items)
        hoverButton.tintColor = .white
        
        view.addSubviews([hoverButton])
    }
    
    override func configureConstraint() {
        super.configureConstraint()
        
        hoverButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // Toggle edit mode
    func toggleEditMode() {
        isMultiUser = false
    }
}

// MARK: - Additional function -
extension CreatePackageViewController {
    
    // Multiuser button pressed
    @objc func enterMultiUserPressed() {
        
        presentLeavingAlert(
            title: "You are about to enter multi-user mode",
            message: "Save or publish before leaving") { leaveKind in
                
            switch leaveKind {
            case .publish: print("1")
            case .saveAsDraft: print("2")
            case .discardChanges: print("3")
            }
            
            let multiVC = MultiUserViewController()
            multiVC.enterKind = .enter
            self.navigationController?.pushViewController(multiVC, animated: true)
        }
    }
    
    // Create multi-user session pressed
    @objc func createSessionPressed() {
        presentLeavingAlert(
            title: "You are about to enter multi-user mode",
            message: "Save or publish before leaving") { leaveKind in
                
            switch leaveKind {
            case .publish: print("1")
            case .saveAsDraft: print("2")
            case .discardChanges: print("3")
            }
            
            let multiVC = MultiUserViewController()
            multiVC.enterKind = .create
            self.navigationController?.pushViewController(multiVC, animated: true)
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
    
    // Edit bar button pressed
    @objc func editButtonPressed() {
        
        if shouldEdit {
            shouldEdit = false
            tableView.setEditing(false, animated: true)
            
            navigationItem.leftBarButtonItem = editButton
            
        } else {
            shouldEdit = true
            tableView.setEditing(true, animated: true)
            
            navigationItem.leftBarButtonItem = saveButton
        }
    }
    
    // Publish button pressed
    @objc func publishButtonPressed() {
        
        let packageColl = PackageCollection.publishedColl
        let packageState = PackageState.publishedState
        
        // upload package
        presentAlertWithTextField(
            title: "Almost done",
            message: "Please add name for your package",
            buttonText: "Okay") { text in
                guard let text else { return }
                let info = Info(title: text,
                                author: [self.userName],
                                authorEmail: [self.userID],
                                rate: 0.0,
                                state: packageState.rawValue)
                
                self.currentPackage.info = info
                self.currentPackage.regionTags = self.regionTags
                self.currentPackage.weatherModules.sunny = self.sunnyModules
                self.currentPackage.weatherModules.rainy = self.rainyModules
                
                self.firestoreManager.uploadPackage(self.currentPackage) { [weak self] result in
                    switch result {
                    case .success(let documentID):
                        self?.firestoreManager.updateUserPackages(
                            email: self?.userID ?? "",
                            packageType: packageColl,
                            docPath: documentID,
                            perform: .add
                        ) {
                            self?.sunnyModules = []
                            self?.rainyModules = []
                            
                            self?.currentPackage = Package()
                            self?.currentPackage.regionTags = []
                            self?.regionTags = []
                            
                            DispatchQueue.main.async {
                                self?.tableView.reloadData()
                            }
                        }
                        
                    case .failure(let error):
                        print("publish failed: \(error)")
                    }
                }
            }
    }
}

// MARK: - Alert Function -
extension CreatePackageViewController {
    // setup alert
    func presentLeavingAlert(
        title: String,
        message: String,
        buttonAction: ((LeaveKind) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        // Publish action
        let pubAction = UIAlertAction(title: "Publish", style: .default) { _ in
            buttonAction?(LeaveKind.publish)
        }
        alert.addAction(pubAction)
        
        // Save as draft action
        let draftAction = UIAlertAction(title: "Save as draft", style: .default) { _ in
            buttonAction?(LeaveKind.saveAsDraft)
        }
        alert.addAction(draftAction)
        
        let leaveWithoutSaveAction = UIAlertAction(title: "Leave without saving", style: .default) { _ in
            buttonAction?(LeaveKind.discardChanges)
        }
        alert.addAction(leaveWithoutSaveAction)
        
        // Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}

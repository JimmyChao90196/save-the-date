//
//  MultiUserVC.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/23.
//

import Foundation
import UIKit

import SnapKit
import CoreLocation

import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseCore

import Hover

enum EnterKind {
    case create
    case enter
}

enum LeaveKind {
    case saveAsDraft
    case publish
    case discardChanges
}

class MultiUserViewController: CreatePackageViewController {
    
    // Store listener
    var LSG: ListenerRegistration?
    
    var enterKind = EnterKind.enter
    
    var switchUserID: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        // Your logic to customize the button
        button.backgroundColor = .blue
        button.setTitle("red", for: .normal)
        
        return button
    }()
        
    // MARK: - Common function -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create or enter session
        switch enterKind {
        case .create:
            createSessionTapped()
            
        case .enter:
            enterSesstionTapped()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isMultiUser = true
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func addTo() {
        super.addTo()
        view.addSubviews([switchUserID])
    }
    
    override func setup() {
        super.setup()
        // Adding an action
        switchUserID.addTarget(self, action: #selector(switchUserIDPressed), for: .touchUpInside)
    }
    
    override func setupHover() {
        super.setupHover()
        
        // Hover button
        let config = HoverConfiguration(
            image: UIImage(systemName: "square.and.arrow.up"),
            color: .color(.hexToUIColor(hex: "#FF4E4E")),
            size: 50,
            imageSizeRatio: 0.7
        )
        
        let itemsMU = [
            HoverItem(
                title: "Leave multi-user session",
                image: UIImage(systemName: "xmark"),
                onTap: { self.leaveMultiUserPressed()})
        ]
        
        hoverButton = HoverView(with: config, items: itemsMU)
        hoverButton.tintColor = .white
        
        view.addSubviews([hoverButton])
    }
    
    override func configureConstraint() {
        super.configureConstraint()
        
        switchUserID.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalTo(50)
        }
    }
    
    // MARK: - Additional function -
    
    // Firestore function implementation
    func updateNameAndEmail(sessionId: String, name: String, email: String) {
        // Add user name and email to package
        self.firestoreManager.updatePackage(
            infoToUpdate: "Jimmy",
            packageType: .sessionColl,
            packageID: sessionId,
            toPath: .author,
            perform: .add) {}
        
        self.firestoreManager.updatePackage(
            infoToUpdate: "jimmy@gmail.com",
            packageType: .sessionColl,
            packageID: sessionId,
            toPath: .authorEmail,
            perform: .add) {}
    }
    
    
    // after Event
    func setupAfterEvent(packageId: String) {
        afterEditComfirmed = { _, time in
            
            self.currentPackage.weatherModules.sunny = self.sunnyModules
            self.currentPackage.weatherModules.rainy = self.rainyModules
            
            self.firestoreManager.updateModulesWithTrans(
                packageId: packageId,
                time: time,
                when: self.weatherState,
                localSunnyModules: self.currentPackage.weatherModules.sunny,
                localRainyModules: self.currentPackage.weatherModules.rainy
                ) { newPackage in
                    self.currentPackage = newPackage
                    self.sunnyModules = newPackage.weatherModules.sunny
                }
        }
        
        afterAppendComfirmed = { targetModule in
            self.firestoreManager.appendModuleWithTrans(
                packageId: packageId,
                userId: self.userID,
                isNewDay: false,
                when: self.weatherState,
                with: targetModule)
        }
    }
    
    // Triggered functions
    @objc func switchUserIDPressed() {
        if switchUserID.titleLabel?.text == "red" {
            switchUserID.setTitle("jimmy", for: .normal)
            userID = "jimmy@gmail.com"
            userName = "Jimmy"
        } else {
            switchUserID.setTitle("red", for: .normal)
            userID = "red@gmail.com"
            userName = "Red"
        }
    }
    
    // Leave multi-user
    @objc func leaveMultiUserPressed() {
        
        presentLeavingAlert(
            title: "You're about to enter normal mode",
            message: "Save or publish before leaving") { leaveKind in
                
            switch leaveKind {
            case .publish: print("1")
            case .saveAsDraft: print("2")
            case .discardChanges: print("Leave without saving")
                
            }
            
            self.LSG?.remove()
            self.sunnyModules = []
            self.rainyModules = []
            self.currentPackage = Package()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // Create session pressed
    @objc func createSessionTapped() {
        
        let packageColl = PackageCollection.sessionColl
        let packageState = PackageState.sessitonState
        
        // upload package
        presentAlertWithTextField(
            title: "Warning",
            message: "Please add name for your Session package",
            buttonText: "Okay") { text in
                guard let text else { return }
                let info = Info(title: text,
                                author: ["Red"],
                                authorEmail: ["red@gmail.com"],
                                rate: 0.0,
                                state: packageState.rawValue)
                
                self.currentPackage.info = info
                self.currentPackage.weatherModules.sunny = self.sunnyModules
                self.currentPackage.weatherModules.rainy = self.rainyModules
                self.firestoreManager.uploadPackage(self.currentPackage, packageColl) { [weak self] result in
                    
                    switch result {
                    case .success(let documentID):
                        self?.firestoreManager.updateUserPackages(
                            email: "red@gmail.com",
                            packageType: packageColl,
                            packageID: documentID,
                            perform: .add
                        ) {
                            
                            // Setup listener
                            self?.LSG = self?.firestoreManager.modulesListener(packageId: documentID) { newPackage in
                                self?.sunnyModules = newPackage.weatherModules.sunny
                                self?.rainyModules = newPackage.weatherModules.rainy
                                
                                DispatchQueue.main.async {
                                    self?.tableView.reloadData()
                                }
                            }
                            
                            self?.sessionID = documentID
                            self?.isMultiUser = true
                            self?.setupAfterEvent(packageId: documentID)
                            
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
    
    @objc func enterSesstionTapped() {
        presentAlertWithTextField(
            title: "Warning",
            message: "Please enter the session ID",
            buttonText: "Okay") { text in
                guard let text else { return }
                
                Task {
                    let sessionPackage = try? await self.firestoreManager.fetchPackage(
                        in: .sessionColl,
                        withID: text)
                    
                    self.currentPackage = sessionPackage ?? Package()
                    self.sunnyModules = self.currentPackage.weatherModules.sunny
                    self.rainyModules = self.currentPackage.weatherModules.rainy
                    
                    // Add name and email
                    self.updateNameAndEmail(sessionId: text, name: "Jimmy", email: "jimmy@gmail.com")
                    
                    // Setup listener
                    self.LSG = self.firestoreManager.modulesListener(packageId: text) { newPackage in
                        
                        self.sunnyModules = newPackage.weatherModules.sunny
                        self.rainyModules = newPackage.weatherModules.rainy
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                    
                    self.sessionID = text
                    self.isMultiUser = true
                    self.setupAfterEvent(packageId: text)
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
    }
}

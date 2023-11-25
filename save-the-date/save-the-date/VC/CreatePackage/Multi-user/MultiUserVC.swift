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

class MultiUserViewController: CreatePackageViewController {
    
    var switchUserID: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        // Your logic to customize the button
        button.backgroundColor = .blue
        button.setTitle("red", for: .normal)
        
        return button
    }()
    
    var createSession: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        // Your logic to customize the button
        button.backgroundColor = .blue
        button.setTitle("Create session", for: .normal)
        
        return button
    }()
    
    var enterSession: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        // Your logic to customize the button
        button.backgroundColor = .blue
        button.setTitle("Enter session", for: .normal)
        
        return button
    }()
    
    // MARK: - Common function -
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func addTo() {
        super.addTo()
        view.addSubviews([createSession, enterSession, switchUserID])
    }
    
    override func setup() {
        super.setup()
        // Adding an action
        createSession.addTarget(self, action: #selector(createSessionTapped), for: .touchUpInside)
        enterSession.addTarget(self, action: #selector(enterSesstionTapped), for: .touchUpInside)
        switchUserID.addTarget(self, action: #selector(switchUserIDPressed), for: .touchUpInside)
        
        enterMultiUser.isHidden = true
        
    }
    
    override func configureConstraint() {
        super.configureConstraint()
        
        switchUserID.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.top.equalTo(createSession.snp.bottom).offset(5)
            make.height.equalTo(50)
            make.width.equalTo(50)
        }
        
        createSession.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalTo(50)
        }
        
        enterSession.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalTo(50)
        }
    }
    
    // MARK: - Additional function -
    
    // after Event
    func setupAfterEvent(packageId: String) {
        
        afterLocationComfirmed = { rawIndex, time in
            self.firestoreManager.updateModulesWithTrans(
                packageId: packageId,
                time: time,
                currentModules: self.sunnyModules,
                localPackage: self.currentPackage) { newPackage in
                    self.currentPackage = newPackage
                    self.sunnyModules = newPackage.weatherModules.sunny
                }
        }
        
        afterAppendLocationComfirmed = { targetModule in
            self.firestoreManager.appendModuleWithTrans(
                packageId: packageId,
                userId: self.userID,
                with: targetModule)
        }
    }
    
    // Triggered events
    @objc func switchUserIDPressed() {
        if switchUserID.titleLabel?.text == "red" {
            switchUserID.setTitle("jimmy", for: .normal)
            userID = "jimmy@gmail.com"
        } else {
            switchUserID.setTitle("red", for: .normal)
            userID = "red@gmail.com"
        }
    }
    
    // Create session pressed
    @objc func createSessionTapped() {
        addNewDayPressed()
        
        let packageColl = PackageCollection.sessionColl
        let packageState = PackageState.sessitonState
        
        // upload package
        presentAlertWithTextField(
            title: "Warning",
            message: "Please add name for your Session package",
            buttonText: "Okay") { text in
                guard let text else { return }
                let info = Info(title: text,
                                author: "red",
                                authorEmail: "red@gmail.com",
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
                            self?.firestoreManager.modulesListener(packageId: documentID) { modules in
                                self?.sunnyModules = modules
                                
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
                    
                    // Setup listener
                    self.firestoreManager.modulesListener(packageId: text) { modules in
                        self.sunnyModules = modules
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

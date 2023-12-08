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
    case deepLink(String)
}

enum LeaveKind {
    case saveAsDraft
    case publish
    case discardChanges
}

class MultiUserViewController: CreatePackageViewController {
    
    // Check entering way
    var isEnteringWithLink = false
    
    // Store listener
    var LSG: ListenerRegistration?
    
    var enterKind = EnterKind.enter
    
    // Chat bundle
    var currentBundle = ChatBundle(
        messages: [],
        participants: [],
        roomID: "")
    
    // VM
    var count = 0
    var viewModle = MultiUserViewModel()
    
    // MARK: - Common function -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Data binding
        viewModle.currentChatBundle.bind { [weak self] bundle in
                
            guard let self = self else { return }
            
            if self.count >= 1 {
            self.currentBundle = bundle
            
                viewModle.updatePackage(
                    pathToUpdate: bundle.roomID,
                    packageToUpdate: documentPath)
            }
        }
        
        self.count += 1
        
        // Create or enter session
        switch enterKind {
        case .create:
            createSessionTapped()
            
        case .enter:
            enterSesstionTapped()
            
        case .deepLink(let docPath):
            enterSesstionWithLinkTapped(docPath: docPath)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isMultiUser = true
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func setup() {
        super.setup()
        
        // Add navigation title
        navigationItem.title = "Multi-user mode"
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
                onTap: { self.leaveMultiUserPressed()}),
            
            HoverItem(
                title: "Share session ID",
                image: UIImage(systemName: "figure.stand.line.dotted.figure.stand"),
                onTap: { self.prepareShareSheet()})
        ]
        
        hoverButton = HoverView(with: config, items: itemsMU)
        hoverButton.tintColor = .white
        
        view.addSubviews([hoverButton])
    }
    
    // MARK: - Additional function -
    // Firestore function implementation
    func updateNameAndEmail(sessionId: String, name: String, email: String) {
        // Add user name and email to package
        self.firestoreManager.updatePackage(
            infoToUpdate: self.userName,
            docPath: sessionId,
            toPath: .author,
            perform: .add) {}
        
        self.firestoreManager.updatePackage(
            infoToUpdate: self.userID,
            docPath: sessionId,
            toPath: .authorEmail,
            perform: .add) {}
    }
    
    // after Event
    func setupAfterEvent(docPath: String) {
        afterEditComfirmed = { _, time in
            
            self.currentPackage.weatherModules.sunny = self.sunnyModules
            self.currentPackage.weatherModules.rainy = self.rainyModules
            
            self.firestoreManager.updateModulesWithTrans(
                docPath: docPath,
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
                docPath: docPath,
                userId: self.userID,
                isNewDay: false,
                when: self.weatherState,
                with: targetModule)
        }
    }
    
    // MARK: - Triggered functions -
    func prepareShareSheet() {
        if let shareUrl = URL(string: "saveTheDate://joinSession?id=\(documentPath)") {
            
            let shareSheetVC = UIActivityViewController(
                activityItems: [shareUrl],
                applicationActivities: nil)
            present(shareSheetVC, animated: true)
        }
    }
    
    // Leave multi-user
    @objc func leaveMultiUserPressed() {
        
        presentLeavingAlert(
            title: "You're about to enter normal mode",
            message: "Save or publish before leaving") { leaveKind in
                
                switch leaveKind {
                case .publish: self.publishPressedMU()
                    
                case .saveAsDraft: print("2")
                    
                case .discardChanges: print("Leave without saving")
                    self.sunnyModules = []
                    self.rainyModules = []
                    self.currentPackage = Package()
                    self.LSG?.remove()
                    
                    self.navigationController?.popViewController(animated: true)
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
    }
    
    // Create session pressed
    @objc func createSessionTapped() {
        
        let packageColl = PackageCollection.sessionColl
        let packageState = PackageState.sessitonState
        
        presentAlertWithTextField(
            title: "Please enter a temporary name first",
            message: "You could change it later",
            buttonText: "Confirm") { sessionName in
                
                // Prepare to upload newPackage
                let info = Info(title: sessionName ?? "unName",
                                author: [self.userName],
                                authorEmail: [self.userID],
                                rate: 0.0,
                                state: packageState.rawValue)
                
                self.currentPackage.info = info
                self.currentPackage.photoURL = self.userManager.currentUser.photoURL
                self.currentPackage.weatherModules.sunny = self.sunnyModules
                self.currentPackage.weatherModules.rainy = self.rainyModules
                
                self.firestoreManager.uploadPackage(self.currentPackage, packageColl) { [weak self] result in
                    
                    // Show loading
                    LKProgressHUD.show()
                    
                    switch result {
                    case .success(let docPath):
                        self?.firestoreManager.updateUserPackages(
                            email: self?.userID ?? "",
                            packageType: packageColl,
                            docPath: docPath,
                            perform: .add
                        ) {
                            
                            // Setup listener
                            self?.LSG = self?.firestoreManager.modulesListener(docPath: docPath) { newPackage in
                                self?.sunnyModules = newPackage.weatherModules.sunny
                                self?.rainyModules = newPackage.weatherModules.rainy
                                
                                DispatchQueue.main.async {
                                    self?.tableView.reloadData()
                                }
                            }
                            
                            self?.documentPath = docPath
                            self?.isMultiUser = true
                            self?.setupAfterEvent(docPath: docPath)
                            
                            // Dismiss loading
                            LKProgressHUD.dismiss()
                            
                            DispatchQueue.main.async {
                                self?.tableView.reloadData()
                            }
                            
                            // Create chatroom
                            guard let currentEmail = self?.userManager.currentUser.email else { return }
                            self?.viewModle.createChatRoom(with: [currentEmail])
                            
                        }
                        
                    case .failure(let error):
                        print("publish failed: \(error)")
                        
                        // Dismiss loading
                        LKProgressHUD.dismiss()
                    }
                }
            }
    }
    
    @objc func enterSesstionTapped() {
        presentAlertWithTextField(
            title: "Warning",
            message: "Please enter the session ID",
            buttonText: "Okay") { text in
                guard let text else {
                    
                    self.navigationController?.popViewController(animated: true)
                    return
                }
                
                Task {
                    
                    var copyText = text
                    
                    switch self.enterKind {
                        
                    case .deepLink(let path):
                        copyText = path
                        
                    default:
                        copyText = text
                    }
                    
                    let sessionPackage = try? await self.firestoreManager.fetchPackage(withID: copyText)
                    
                    self.currentPackage = sessionPackage ?? Package()
                    self.sunnyModules = self.currentPackage.weatherModules.sunny
                    self.rainyModules = self.currentPackage.weatherModules.rainy
                    
                    // Add name and email
                    self.updateNameAndEmail(
                        sessionId: text,
                        name: self.userName,
                        email: self.userID)
                    
                    // Update user packages
                    self.firestoreManager.updateUserPackages(
                        email: self.userID,
                        packageType: .sessionColl,
                        docPath: text,
                        perform: .add) { }
                    
                    // Setup listener
                    self.LSG = self.firestoreManager.modulesListener(docPath: text) { newPackage in
                        
                        self.currentPackage = newPackage
                        self.sunnyModules = newPackage.weatherModules.sunny
                        self.rainyModules = newPackage.weatherModules.rainy
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                    
                    self.documentPath = text
                    self.isMultiUser = true
                    self.setupAfterEvent(docPath: text)
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                    // Update chatroom at the end
                    let currentEmail = self.userManager.currentUser.email
                    let chatDocPath = self.self.currentPackage.chatDocPath
                    self.viewModle.updateChatRoom(newEmail: currentEmail, docPath: chatDocPath)
                }
            }
    }
    
    @objc func enterSesstionWithLinkTapped(docPath: String) {
        
        Task {
            
            let sessionPackage = try? await self.firestoreManager.fetchPackage(withID: docPath)
            
            self.currentPackage = sessionPackage ?? Package()
            self.sunnyModules = self.currentPackage.weatherModules.sunny
            self.rainyModules = self.currentPackage.weatherModules.rainy
            
            // Add name and email
            self.updateNameAndEmail(
                sessionId: docPath,
                name: self.userName,
                email: self.userID)
            
            // Update user packages
            self.firestoreManager.updateUserPackages(
                email: self.userID,
                packageType: .sessionColl,
                docPath: docPath,
                perform: .add) { }
            
            // Setup listener
            self.LSG = self.firestoreManager.modulesListener(docPath: docPath) { newPackage in
                
                self.currentPackage = newPackage
                self.sunnyModules = newPackage.weatherModules.sunny
                self.rainyModules = newPackage.weatherModules.rainy
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
            self.documentPath = docPath
            self.isMultiUser = true
            self.setupAfterEvent(docPath: docPath)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
            // Update chatroom at the end
            let currentEmail = self.userManager.currentUser.email
            let chatDocPath = self.self.currentPackage.chatDocPath
            self.viewModle.updateChatRoom(newEmail: currentEmail, docPath: chatDocPath)
        }
    }
    
    // publish button
    func publishPressedMU() {
        
        let packageColl = PackageCollection.publishedColl
        
        // upload package
        presentAlertWithTextField(
            title: "Almost done",
            message: "Please add name for your package",
            buttonText: "Okay") { text in
                guard let text else { return }
                
                self.currentPackage.info.title = text
                print("\(self.currentPackage.info.authorEmail)")
                
                self.currentPackage.photoURL = self.userManager.currentUser.photoURL
                self.currentPackage.weatherModules.sunny = self.sunnyModules
                self.currentPackage.weatherModules.rainy = self.rainyModules
                
                self.firestoreManager.uploadPackage(self.currentPackage) { [weak self] result in
                    switch result {
                    case .success(let docPath):
                        
                        let dispatchGroup = DispatchGroup()
                        for email in self?.currentPackage.info.authorEmail ?? [] {
                            dispatchGroup.enter()
                            self?.firestoreManager.updateUserPackages(
                                email: email,
                                packageType: packageColl,
                                docPath: docPath,
                                perform: .add
                            ) {
                                dispatchGroup.leave()
                            }
                        }
                        
                        dispatchGroup.notify(queue: .main) {
                            self?.sunnyModules = []
                            self?.rainyModules = []
                            self?.currentPackage = Package()
                            self?.LSG?.remove()
                            
                            DispatchQueue.main.async {
                                self?.tableView.reloadData()
                            }
                            
                            self?.navigationController?.popViewController(animated: true)
                            
                        }
                    case .failure(let error):
                        print("publish failed: \(error)")
                    }
                }
            }
    }
}

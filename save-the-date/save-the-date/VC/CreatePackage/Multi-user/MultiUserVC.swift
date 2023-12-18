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
    case demo(String)
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
            
        case .demo(let id):
            print("about to enter demo session: \(id)")
            enterSesstionTapped()
            
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
    func updateNameAndUid(sessionId: String, name: String, uid: String) {
        // Add user name and userId to package
        self.firestoreManager.updatePackage(
            infoToUpdate: self.userName,
            docPath: sessionId,
            toPath: .author,
            perform: .add) {}
        
        self.firestoreManager.updatePackage(
            infoToUpdate: self.userID,
            docPath: sessionId,
            toPath: .authorId,
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
                                authorId: [self.userID],
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
                            userId: self?.userID ?? "",
                            packageType: packageColl,
                            docPath: docPath,
                            perform: .add
                        ) {
                            
                            // Setup listener
                            self?.LSG = self?.firestoreManager.modulesListener(docPath: docPath) { newPackage in
                                self?.currentPackage = newPackage
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
                            guard let currentId = self?.userManager.currentUser.uid else { return }
                            self?.viewModle.createChatRoom(with: [currentId])
                            
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
        
        var id = "sessionPackages/"
        
        switch self.enterKind {
            
        case .demo(let demoId):
            id = "sessionPackages/\(demoId)"
            enterSessionHelper(id: id)
            
        default:
            
            presentAlertWithTextField(
                title: "Warning",
                message: "Please enter the session ID",
                buttonText: "Okay") { text in
                    guard let text else {
                        self.navigationController?.popViewController(animated: true)
                        return }
                    id = "sessionPackages/\(text)"
                    self.enterSessionHelper(id: id)
                }
        }
    }
    
    @objc func enterSesstionWithLinkTapped(docPath: String) {
        
        Task {
            
            let sessionPackage = try? await self.firestoreManager.fetchPackage(withID: docPath)
            
            self.currentPackage = sessionPackage ?? Package()
            self.sunnyModules = self.currentPackage.weatherModules.sunny
            self.rainyModules = self.currentPackage.weatherModules.rainy
            
            // Add name and id
            self.updateNameAndUid(
                sessionId: docPath,
                name: self.userName,
                uid: self.userID)
            
            // Update user packages
            self.firestoreManager.updateUserPackages(
                userId: self.userID,
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
            let currentUid = self.userManager.currentUser.uid
            let chatDocPath = self.self.currentPackage.chatDocPath
            self.viewModle.updateChatRoom(newId: currentUid, docPath: chatDocPath)
        }
    }
    
    // Helper function when entering the session
    func enterSessionHelper(id: String) {
        Task {
            
            let sessionPackage = try? await
            self.firestoreManager.fetchPackage(withID: id)
            
            if sessionPackage == nil {
                
                LKProgressHUD.showFailure(text: "Wrong session ID")
                self.navigationController?.popViewController(animated: true)
                return
            }
            
            self.currentPackage = sessionPackage ?? Package()
            self.sunnyModules = self.currentPackage.weatherModules.sunny
            self.rainyModules = self.currentPackage.weatherModules.rainy
            
            // Add name and uid
            self.updateNameAndUid(
                sessionId: id,
                name: self.userName,
                uid: self.userID)
            
            // Update user packages
            self.firestoreManager.updateUserPackages(
                userId: self.userID,
                packageType: .sessionColl,
                docPath: id,
                perform: .add) { }
            
            // Setup listener
            self.LSG = self.firestoreManager.modulesListener(docPath: id) { newPackage in
                
                self.currentPackage = newPackage
                self.sunnyModules = newPackage.weatherModules.sunny
                self.rainyModules = newPackage.weatherModules.rainy
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
            self.documentPath = id
            self.isMultiUser = true
            self.setupAfterEvent(docPath: id)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
            // Update chatroom at the end
            let currentUid = self.userManager.currentUser.uid
            let chatDocPath = self.self.currentPackage.chatDocPath
            self.viewModle.updateChatRoom(newId: currentUid, docPath: chatDocPath)
        }
    }
    
    // publish button
    func publishPressedMU() {
        
        let packageColl = PackageCollection.publishedColl
        
        let shouldPub = self.viewModel.shouldPublish(
            sunnyModule: self.sunnyModules,
            rainyModule: self.rainyModules)
        
        if !shouldPub {
            // upload package
            presentSimpleAlert(
                title: "Error",
                message: "Please at least add a location for this package",
                buttonText: "Okay") {
                    return
                }
        }
        
        // upload package
        presentAlertWithTextField(
            title: "Almost done",
            message: "Please add name for your package",
            buttonText: "Okay") { text in
                guard let text else { return }
                
                self.currentPackage.info.title = text
                print("\(self.currentPackage.info.authorId)")
                
                self.currentPackage.photoURL = self.userManager.currentUser.photoURL
                self.currentPackage.regionTags = self.regionTags
                self.currentPackage.weatherModules.sunny = self.sunnyModules
                self.currentPackage.weatherModules.rainy = self.rainyModules
                
                self.firestoreManager.uploadPackage(self.currentPackage) { [weak self] result in
                    switch result {
                    case .success(let docPath):
                        
                        let dispatchGroup = DispatchGroup()
                        for uid in self?.currentPackage.info.authorId ?? [] {
                            dispatchGroup.enter()
                            self?.firestoreManager.updateUserPackages(
                                userId: uid,
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

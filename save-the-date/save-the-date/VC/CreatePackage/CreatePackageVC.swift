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

class CreatePackageViewController: PackageBaseViewController {
    
    var publishButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        
        button.setbackgroundColor(.hexToUIColor(hex: "#FF4E4E"))
            .setCornerRadius(40)
            .setBoarderColor(.hexToUIColor(hex: "#3F3A3A"))
            .setBoarderWidth(2.5)
        
        button.setTitle("Publish", for: .normal)
        button.titleLabel?.setFont(UIFont(name: "ChalkboardSE-Bold", size: 18)!)
        button.setTitleColor(.white, for: .normal)
        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let editBarButton = UIBarButtonItem(
            barButtonSystemItem: .edit,
            target: self,
            action: #selector(editButtonPressed))
        navigationItem.leftBarButtonItem = editBarButton
    }
    
    // MARK: - Basic function -
    
    override func addTo() {
        super.addTo()
        view.addSubviews([publishButton])
    }
    
    override func setup() {
        super.setup()
        
        tableView.backgroundColor = .clear
        
        publishButton.addTarget(
            self,
            action: #selector(publishButtonPressed),
            for: .touchUpInside)

        let rightBarButton = UIBarButtonItem(customView: addNewDayButton)
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    override func configureConstraint() {
        super.configureConstraint()
        
        publishButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-15)
            make.bottom.equalTo(view.snp_bottomMargin).offset(-10)
            make.width.equalTo(80)
            make.height.equalTo(80)
        }
    }
}

// MARK: - Additional function -

extension CreatePackageViewController {

    // Add empty pressed
    @objc func addNewDayPressed() {
        
        switch weatherState {
            
        case .sunny:
            
            let uniqueSet = Set(sunnyModules.compactMap { $0.day })
            let module = PackageModule(day: uniqueSet.count)
            
            self.sunnyModules.append(module)
            
        case .rainy:
            
            let uniqueSet = Set(rainyModules.compactMap { $0.day })
            let module = PackageModule(day: uniqueSet.count)
            
            self.rainyModules.append(module)
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // Edit bar button pressed
    @objc func editButtonPressed() {
        tableView.setEditing(!tableView.isEditing, animated: true)
    }
    
    // Publish button pressed
    @objc func publishButtonPressed() {
        
        let packageColl = PackageCollection.publishedColl
        let packageState = PackageState.publishedState
        
        // Publish package
        presentAlertWithTextField(
            title: "Almost done",
            message: "Please add name for your package",
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
                
                self.firestoreManager.publishPackageWithJson(self.currentPackage) { [weak self] result in
                    switch result {
                    case .success(let documentID):
                        self?.firestoreManager.updateUserPackages(
                            email: "red@gmail.com",
                            packageType: .publishedColl,
                            packageID: documentID,
                            perform: .add
                        ) {
                                self?.sunnyModules = []
                                self?.rainyModules = []
                                self?.currentPackage = Package()
                                
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

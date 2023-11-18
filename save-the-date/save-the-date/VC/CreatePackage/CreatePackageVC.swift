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
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        
        button.backgroundColor = .red
        button.setTitle("Publish", for: .normal)
        
        return button
    }()
    
    // MARK: - Basic function -
    
    override func addTo() {
        super.addTo()
        view.addSubviews([publishButton])
    }
    
    override func setup() {
        super.setup()
        
        publishButton.addTarget(
            self,
            action: #selector(publishButtonPressed),
            for: .touchUpInside)
    }
    
    override func configureConstraint() {
        super.configureConstraint()
        publishButton.snp.makeConstraints { make in
            make.centerY.equalTo(showRoute)
            make.leading.equalTo(showRoute.snp.trailing).offset(10)
            make.width.equalTo(60)
            make.height.equalTo(50)
        }
    }
}

// MARK: - Additional function -

extension CreatePackageViewController {
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
                                author: "Jimmy",
                                rate: 0,
                                state: packageState.rawValue)
                
                let packageModules = self.packageManager.packageModules
                let package = Package(info: info, packageModules: packageModules)
                self.firestoreManager.publishPackage(package) { [weak self] result in
                    switch result {
                    case .success(let documentID):
                        self?.firestoreManager.updateUserPackages(
                            email: "jimmy@gmail.com",
                            packageType: packageColl.rawValue,
                            packageID: documentID) {
                                self?.packageManager.packageModules = []
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

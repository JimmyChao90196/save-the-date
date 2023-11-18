//
//  ExploreBaseVC.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/18.
//

import Foundation
import UIKit

import SnapKit
import CoreLocation

import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseCore

class ExploreBaseViewController: UIViewController {
    var tableView = ExploreTableView()
    var googlePlaceManager = GooglePlacesManager.shared
    var firestoreManager = FirestoreManager.shared
    var routeManager = RouteManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        addTo()
        setupConstraint()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setup() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func addTo() {
        view.addSubviews([tableView])
    }
    
    func setupConstraint() {
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.snp_topMargin)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.bottom.equalTo(view.snp_bottomMargin)
        }
    }
}

// MARK: - Delegate method -
extension ExploreBaseViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    // Did select row at
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    // Cell for row at
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ExploreTableViewCell.reuseIdentifier,
            for: indexPath) as? ExploreTableViewCell else {
            return UITableViewCell() }
        
        cell.packageTitleLabel.text = "\(10)"
        
        return cell
    }
}

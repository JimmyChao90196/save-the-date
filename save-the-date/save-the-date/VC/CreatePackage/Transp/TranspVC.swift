//
//  TranspViewController.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/16.
//

import UIKit
import CoreLocation

protocol TranspViewControllerDelegate: AnyObject {
    func didTapTransp(with coordinate: CLLocationCoordinate2D, targetTransp: Transportation)
}

class TranspViewController: UIViewController {

    var delgate: TranspViewControllerDelegate?
    var tableView = TranspTableView()
    var onTranspTapped: ((UITableViewCell) -> Void)?
    var onTranspComfirm: ((TranspManager, ActionKind, TimeInterval) -> Void)?
    var timeStamp: TimeInterval = 0
    
    // Set action kind
    var actionKind = ActionKind.edit(IndexPath())
    
    private var transportation: [Transportation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        view.backgroundColor = .clear
        
        addTo()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func addTo() {
        view.addSubviews([tableView])
    }
}

// MARK: - Delegate and dataSource method -
extension TranspViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        TranspManager.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TranspTableViewCell.reuseIdentifier,
            for: indexPath) as?
                TranspTableViewCell
        else { return UITableViewCell() }
        
        let iconName = TranspManager.allCases[indexPath.row].transIcon
        cell.transIcon.image = UIImage(systemName: iconName)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Deselect row
        tableView.deselectRow(at: indexPath, animated: true)
        
        let transpManager = TranspManager.allCases[indexPath.row]
        onTranspComfirm?(transpManager, actionKind, timeStamp)
        navigationController?.popViewController(animated: true)
    }
}

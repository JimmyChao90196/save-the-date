//
//  TranspViewController.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/16.
//

import UIKit
import CoreLocation
import Lottie
import SnapKit

protocol TranspViewControllerDelegate: AnyObject {
    func didTapTransp(with coordinate: CLLocationCoordinate2D, targetTransp: Transportation)
}

class TranspViewController: UIViewController {
    
    // AnimationView
    var weatherAnimationView = LottieAnimationView()
    
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
        
        // Setup animation
        weatherAnimationView = LottieAnimationView(name: "Weather")
        weatherAnimationView.isUserInteractionEnabled = false
        weatherAnimationView.contentMode = .scaleAspectFit
        weatherAnimationView.play()
        weatherAnimationView.animationSpeed = 0.3
        weatherAnimationView.loopMode = .loop
        
        tableView.delegate = self
        tableView.dataSource = self
        
        view.backgroundColor = .customLightGrey
        tableView.backgroundColor = .clear
        
        addTo()
        setupConstranit()
    }

    private func addTo() {
        view.addSubviews([tableView, weatherAnimationView])
    }
    
    func setupConstranit() {
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.snp_topMargin)
            make.bottom.equalTo(view.snp_bottomMargin)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        weatherAnimationView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(50)
        }
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
        cell.backgroundColor = .clear
        cell.transLabel.text = TranspManager.allCases[indexPath.row].rawValue
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

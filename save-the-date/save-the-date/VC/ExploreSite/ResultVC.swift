//
//  ResultViewController.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/16.
//

import UIKit
import CoreLocation

protocol ResultViewControllerDelegate: AnyObject {
    func didTapPlace(with coordinate: CLLocationCoordinate2D, targetPlace: Location)
}

class ResultViewController: UIViewController {
    
    var delgate: ResultViewControllerDelegate?
    var tableView = ResultTableView()
    var googlePlacesManager = GooglePlacesManager.shared
    
    private var places: [Location] = []
    
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
extension ResultViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ResultTableViewCell.reuseIdentifier,
            for: indexPath) as?
                ResultTableViewCell
        else { return UITableViewCell() }
        
        cell.textLabel?.text = places[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        tableView.isHidden = true
        
        let place = places[indexPath.row]
        googlePlacesManager.resolveLocation(for: place) { [weak self] result in
            switch result {
            case .success(let coordinate):
                
                DispatchQueue.main.async {
                    self?.delgate?.didTapPlace(with: coordinate, targetPlace: place)
                }
                
            case .failure(let error): print(error)
            }
        }
    }
}

// MARK: - Additional function -
extension ResultViewController {
    public func update(with places: [Location]) {
        self.tableView.isHidden = false
        self.places = places
        self.tableView.reloadData()
    }
}

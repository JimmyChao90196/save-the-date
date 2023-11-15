//
//  RequestViewController.swift
//  FireBaseGroup2_iOS
//
//  Created by JimmyChao on 2023/10/24.
//

import UIKit

class CreatePackageViewController: UIViewController {
    
    var tableView = PackageTableView()
    var packageManager = PackageManager()
    var onDelete: ((UITableViewCell) -> Void)?
    var onNumberSent: ( (Int) -> Void )?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        addTo()
        setup()
        configureConstraint()
        setupOnEvent()
        
        // Set bar button
        let addBarButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonPressed))
        navigationItem.rightBarButtonItem = addBarButton
        
        let editBarButton = UIBarButtonItem(
            barButtonSystemItem: .edit,
            target: self,
            action: #selector(editButtonPressed))
        navigationItem.leftBarButtonItem = editBarButton
    }
    
    func addTo() {
        view.addSubviews([tableView])
    }
    
    func setup() {
        tableView.setEditing(false, animated: true)
    }
    
    func configureConstraint() {
        
        tableView.topConstr(to: view.safeAreaLayoutGuide.topAnchor, 0)
            .leadingConstr(to: view.safeAreaLayoutGuide.leadingAnchor, 0)
            .trailingConstr(to: view.safeAreaLayoutGuide.trailingAnchor, 0)
            .bottomConstr(to: view.safeAreaLayoutGuide.bottomAnchor, 0)
    }
}

// MARK: - dataSource method -
extension CreatePackageViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        packageManager.numbers.count
        
    }
    
    // Did select row at
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    // Cell for row at
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ModuleTableViewCell.reuseIdentifier,
            for: indexPath) as? ModuleTableViewCell else {
             return UITableViewCell() }
        
        cell.numberLabel.text = "\(packageManager.numbers[indexPath.row])"
        cell.onDelete = onDelete
        
        return cell
    }
    
    // Can move row at
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        true
    }

    // Move row at
    func tableView(
        _ tableView: UITableView,
        moveRowAt sourceIndexPath: IndexPath,
        to destinationIndexPath: IndexPath) {
            
        let movedObject = self.packageManager.numbers[sourceIndexPath.row]
        self.packageManager.numbers.remove(at: sourceIndexPath.row)
        self.packageManager.numbers.insert(movedObject, at: destinationIndexPath.row)
    }
}

// MARK: - Additional method -
extension CreatePackageViewController {
    
    // Add bar button pressed
    @objc func addButtonPressed() {
        // Go to Explore site and choose one
        let exploreVC = ExploreSiteViewController()
        exploreVC.onNumberSent = onNumberSent
        navigationController?.pushViewController(exploreVC, animated: true)
    }
    
    // Edit bar button pressed
    @objc func editButtonPressed() {
        tableView.setEditing(!tableView.isEditing, animated: true)
    }
    
    // Initialize cell event
    func setupOnEvent() {
        
        // Handle onEvents
        onNumberSent = { [weak self] num in
            self?.packageManager.numbers.append(num)
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        onDelete = { [weak self] cell in
            guard let indexPathToDelete = self?.tableView.indexPath(for: cell) else { return }
            self?.packageManager.numbers.remove(at: indexPathToDelete.row)
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
    }
}

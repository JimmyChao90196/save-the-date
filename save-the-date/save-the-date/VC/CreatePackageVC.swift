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
    
    // On events
    var onDelete: ((UITableViewCell) -> Void)?
    var onLocationComfirm: ( (Location, ActionKind) -> Void )?
    var onLocationTapped: ((UITableViewCell) -> Void)?
    var onTranspTapped: ((UITableViewCell) -> Void)?
    var onTranspComfirm: ((TranspManager, ActionKind) -> Void)?
    
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
        
        packageManager.packageModules.count
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
        
        let iconName = packageManager.packageModules[indexPath.row].transportation.transpIcon
        let locationTitle = "\(packageManager.packageModules[indexPath.row].location.shortName)"
        
        cell.numberLabel.text = locationTitle
        cell.transpIcon.image = UIImage(systemName: iconName)
        
        cell.onDelete = onDelete
        cell.onLocationTapped = self.onLocationTapped
        cell.onTranspTapped = self.onTranspTapped
        
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
            
            let movedObject = self.packageManager.packageModules[sourceIndexPath.row]
            self.packageManager.packageModules.remove(at: sourceIndexPath.row)
            self.packageManager.packageModules.insert(movedObject, at: destinationIndexPath.row)
        }
}

// MARK: - Additional method -
extension CreatePackageViewController {

    // Add bar button pressed
    @objc func addButtonPressed() {
        // Go to Explore site and choose one
        let exploreVC = ExploreSiteViewController()
        exploreVC.onLocationComfirm = onLocationComfirm
        exploreVC.actionKind = .add
        navigationController?.pushViewController(exploreVC, animated: true)
    }
    
    // Edit bar button pressed
    @objc func editButtonPressed() {
        tableView.setEditing(!tableView.isEditing, animated: true)
    }
    
    // Initialize onEvent
    func setupOnEvent() {
        
        onTranspTapped = { [weak self] cell in
            guard let self else { return }
            
            // Jump to transpVC
            let transpVC = TranspViewController()
            transpVC.onTranspComfirm = onTranspComfirm
            transpVC.actionKind = .edit(cell)
            self.navigationController?.pushViewController(transpVC, animated: true)
        }
        
        onLocationTapped = { [weak self] cell in
            guard let self else { return }
            
            let exploreVC = ExploreSiteViewController()
            exploreVC.onLocationComfirm = onLocationComfirm
            exploreVC.actionKind = .edit(cell)
            self.navigationController?.pushViewController(exploreVC, animated: true)
        }
        
        onLocationComfirm = { [weak self] location, action in
            // Dictate action
            
            let module = PackageModule(
                location: location,
                transportation: Transportation(transpIcon: "plus.viewfinder"))
            
            switch action {
            case .add:
                self?.packageManager.packageModules.append(module)
            case .edit(let cell):
                guard let indexPathToEdit = self?.tableView.indexPath(for: cell) else { return }
                self?.packageManager.packageModules[indexPathToEdit.row] = module
            }
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        onTranspComfirm = { [weak self] transp, action in
            // Dictate action
            
            let transportation = Transportation(transpIcon: transp.transIcon)
            
            switch action {
            case .add:
                print("this shouldn't be triggered")
                
            case .edit(let cell):
                guard let indexPathToEdit = self?.tableView.indexPath(for: cell) else { return }
                self?.packageManager.packageModules[indexPathToEdit.row].transportation = transportation
            }
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        onDelete = { [weak self] cell in
            guard let indexPathToDelete = self?.tableView.indexPath(for: cell) else { return }
            self?.packageManager.packageModules.remove(at: indexPathToDelete.row)
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
}

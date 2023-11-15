//
//  RequestViewController.swift
//  FireBaseGroup2_iOS
//
//  Created by JimmyChao on 2023/10/24.
//

import UIKit

class CreatePackageViewController: UIViewController{
    
    var tableView = NumberTableView()
    
    var numReceivedFromButton: ((Int) -> Void)?
    var numReceivedFromCell: ((Int) -> Void)?
    
    //1-3
    var deleteNotifiedByProtocol: (() -> Void)?
    //1-2
    var deleteNotifiedByAddTarget: (() -> Void)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        addTo()
        configureConstraint()
        
        //Set bar button
        let addBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
        navigationItem.rightBarButtonItem = addBarButton
    }

    
    func addTo(){
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    func configureConstraint(){
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    
    
    //Add bar button pressed
    @objc func addButtonPressed(){
        
    }
}



//MARK: - delegate method -

extension CreatePackageViewController: UITableViewDelegate, UITableViewDataSource{
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        guard let cell = tableView.cellForRow(at: indexPath) as? NumberTableViewCell else{ print("cell found nil"); return }
        
        //Go to page 2
        let addVC = AddViewController()
        addVC.numberToRevise = Int(cell.numberLabel.text ?? "0")
        addVC.writtenType = .fromCell
        addVC.delegate = self
        addVC.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(addVC, animated: true)
        
        
        //2-1 Number went back with closure
//                addVC.numberSentFromCell = { num in
//        
//                    self.db.numbers[indexPath.row] = num
//        
//                    DispatchQueue.main.async {
//                        self.tableView.reloadData()
//                    }
//                }
        
        
        //2-2 Number went back with protocol
        self.numReceivedFromCell = { num in
            self.db.numbers[indexPath.row] = num
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NumberTableViewCell.reuseIdentifier, for: indexPath) as? NumberTableViewCell else{ return UITableViewCell() }
        
        cell.numberLabel.text = "\(db.numbers[indexPath.row])"
        
        //MARK: - Page 1 request -
        //1-1 Notified by closure
                cell.onDelete = {
                    guard let indexPathToDelete = tableView.indexPath(for: cell) else{ return }
                    self.db.numbers.remove(at: indexPathToDelete.row)
        
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
        
        
        //1-3 Notified by delegate
//                cell.delegate = self
//                deleteNotifiedByProtocol = {
//                    guard let indexPathToDelete = tableView.indexPath(for: cell) else{ return }
//                    self.db.numbers.remove(at: indexPathToDelete.row)
//        
//                    DispatchQueue.main.async {
//                        self.tableView.reloadData()
//                    }
//                }
        
        //1-2 Notified by add target
//        cell.deleteButton.addTarget(self, action: #selector(deleteButtonPressed), for: .touchUpInside)
//        deleteNotifiedByAddTarget = {
//            
//            guard let indexPathToDelete = tableView.indexPath(for: cell) else{ return }
//            self.db.numbers.remove(at: indexPathToDelete.row)
//            
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
//            
//        }
        
        return cell
    }
}

//MARK: - Delegate method -
extension CreatePackageViewController: numberSentProtocol, deleteProtocol{
    
    //1-1
    func onDelete() {
        self.deleteNotifiedByProtocol?()
    }
    //2-1
    func numberSentByButton(number: Int) {
        self.numReceivedFromButton?(number)
    }
    //2-1
    func numberSentByCell(number: Int) {
        self.numReceivedFromCell?(number)
    }
    
    //MARK: - Add target -
    //1-2
    @objc func deleteButtonPressed(){
        self.deleteNotifiedByAddTarget?()
    }
    
}


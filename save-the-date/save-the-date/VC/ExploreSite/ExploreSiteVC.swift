//
//  ExploreSiteViewController.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/15.
//

import Foundation
import UIKit

class ExploreSiteViewController: UIViewController {
    
    var packageManager = PackageManager.shared
    var numberTextField = UITextField()
    
    var acceptButton = UIButton()
    var onNumberSent: ( (Int) -> Void )?
    var numberToRevise: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        addTo()
        setup()
        setupConstraint()
    }
    
    func setup() {
        numberTextField.placeholder = "Please enter a number"
        numberTextField.textAlignment = .center
        numberTextField.layer.borderColor = UIColor.black.cgColor
        numberTextField.layer.borderWidth = 1
        
        acceptButton.setTitle("Accecpt", for: .normal)
        acceptButton.setTitleColor(.white, for: .normal)
        acceptButton.layer.cornerRadius = 20
        acceptButton.backgroundColor = .black
        acceptButton.layer.borderColor = UIColor.black.cgColor
        acceptButton.layer.borderWidth = 1
        
        acceptButton.addTarget(self, action: #selector(acceptButtonPressed), for: .touchUpInside)
    }

    // MARK: - Accept button pressed
    @objc func acceptButtonPressed() {
        
        guard let number = numberTextField.text else { return }
        
        if number.isEmpty {
            let alert = UIAlertController(title: "Error", message: "Please enter a number", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            
        } else {
            let numberInt = Int(number) ?? 0
            onNumberSent?(numberInt)
            navigationController?.popViewController(animated: true)
        }
    }
    
    func addTo() {
        view.addSubviews([numberTextField, acceptButton])
    }
    
    func setupConstraint() {
        let screenWidth = UIScreen.main.bounds.size.width
        
        NSLayoutConstraint.activate([
            numberTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            numberTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            numberTextField.widthAnchor.constraint(equalToConstant: screenWidth * 0.6666),
            
            acceptButton.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 20),
            acceptButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            acceptButton.widthAnchor.constraint(equalToConstant: screenWidth * 0.6666),
            acceptButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}

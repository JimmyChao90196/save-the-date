//
//  AdminChatVC.swift
//  STYLiSH
//
//  Created by JimmyChao on 2023/11/5.
//  Copyright © 2023 AppWorks School. All rights reserved.
//

import Foundation
import UIKit
import IQKeyboardManagerSwift
import SnapKit

class ChatViewController: UIViewController {
    
    var firebaseManage = FirestoreManager.shared

    var titleView = UILabel()
    var tableView = ChatTableView()
    
    var viewModel = ChatViewModel()
    var userManager = UserManager.shared
    var currentBundle = ChatBundle(messages: [], participants: [], roomID: "")
    
    let footerView = UIView()
    var inputField = UITextField()
    
    // var isUser = false
    var isUserInTheRoom = true
    
    var kickButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        
        // Your logic to customize the button
        button.backgroundColor = .blue
        button.setTitle("leave the room", for: .normal)
        
        return button
    }()
    
    var sendButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        
        button.setImage(UIImage(systemName: "paperplane")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.contentMode = .scaleAspectFill
        return button
    }()
    
    // MARK: - View did load -
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupConstranit()
        tableView.reloadData()
        
        // Listener
        recieveMessage()
        
        // scrollToBottom()
        
        // Binding
        viewModel.currentBundle.bind { bundle in
            
            self.currentBundle = bundle
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
            self.scrollToBottom()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = false
        setNeedsStatusBarAppearanceUpdate()
    }
    
    // MARK: - Additional method
    @objc func sendButtonClicked() {
        guard let text = inputField.text, !text.isEmpty else { return }
        
        // Send message to firebase, but update UI first
        viewModel.sendMessage(
            currentUser: userManager.currentUser,
            inputText: text,
            docPath: currentBundle.roomID
        )
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        scrollToBottom()
        inputField.text = ""
    }
    
    // Kick button action
    @objc func kickButtonClicked() {
        
        presentSimpleAlert(
            title: "Warning",
            message: "User is kicked out",
            buttonText: "Ok") {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func scrollToBottom() {
        
        if tableView.numberOfRows(inSection: 0) == 0 { return }
        
        DispatchQueue.main.async { [self] in
            let indexPath = IndexPath(
                row: tableView.numberOfRows(inSection: 0) - 1,
                section: 0)
            
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    // MARK: - Action for incomming event
    func recieveMessage() {
        
        // MARK: - Handle user leave event -
//        socketIOManager.recievedConnectionResult = { result in
//            
//            switch result {
//            case .success( _ ): print("Yes")
//                
//            case .failure(let connectError):
//                print(connectError)
//                
//                self.presentSimpleAlert(
//                    title: "Error",
//                    message: connectError.rawValue,
//                    buttonText: "Ok")
//            }
//        }
        
        // MARK: - Handle message recieved event -
        
        DispatchQueue.main.async { [self] in
            tableView.reloadData()
            scrollToBottom()
        }
    }
    
    // MARK: - Basic setup -
    func setup() {
        tableView.backgroundColor = .white
        view.backgroundColor = .white
        
        view.addSubviews([tableView, footerView])
        footerView.addSubviews([inputField, sendButton])
        
        sendButton.tintColor = .hexToUIColor(hex: "#3F3A3A")
        
        inputField.textAlignment = .left
        inputField.placeholder = "Aa"
        inputField.setCornerRadius(10)
        inputField.backgroundColor = .hexToUIColor(hex: "#CCCCCC")
        inputField.isEnabled = true
        IQKeyboardManager.shared.enable = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        footerView.backgroundColor = .hexToUIColor(hex: "#F5F5F5")
        footerView.setBoarderColor(.lightGray)
        footerView.setBoarderWidth(1.5)
        
        sendButton.addTarget(self, action: #selector(sendButtonClicked), for: .touchUpInside)
        
        // Create the chatroom
        viewModel.createChatRoom()
    }
    
    func setupConstranit() {
     
        footerView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(50)
        }
        
        inputField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalTo(sendButton.snp.leading).offset(-10)
            make.bottom.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(10)
        }
        
        sendButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
            make.width.equalTo(50)
            make.height.equalTo(50)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.topMargin)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(footerView.snp.top)
        }

    }
}

// MARK: - Delegate and DataSource method -
extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        currentBundle.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let userEmail = currentBundle.messages[indexPath.row].userEmail
        
        let isUser = userEmail == userManager.currentUser.email ? true: false
        
        switch isUser {
        case true:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ChatRightTableViewCell.reuseIdentifier,
                for: indexPath
            ) as? ChatRightTableViewCell else { return UITableViewCell()}
            
            cell.messageLabel.text =
            currentBundle.messages[indexPath.row].content
            
            cell.timeLabel.text =
            currentBundle.messages[indexPath.row].sendTime.customFormat()
            
            cell.backgroundColor = .clear
            
            return cell
            
        case false:
            
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ChatLeftTableViewCell.reuseIdentifier,
                for: indexPath
            ) as? ChatLeftTableViewCell else { return UITableViewCell()}
            
            cell.profilePic.image = UIImage(systemName: "person.circle")
            
            cell.messageLabel.text =
            currentBundle.messages[indexPath.row].content
            
            cell.timeLabel.text =
            currentBundle.messages[indexPath.row].sendTime.customFormat()
            
            cell.backgroundColor = .clear

            return cell
        }
    }
}

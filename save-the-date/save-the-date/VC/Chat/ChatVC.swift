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

class ChatViewController: UIViewController {
    
    // let chatManager = ChatManager.shared
    var firebaseManage = FirestoreManager.shared

    var titleView = UILabel()
    var tableView = ChatTableView()
    
    var viewModel = ChatViewModel()
    var userManager = UserManager.shared
    
    let footerView = UIView()
    var inputField = UITextField()
    
    // var isUser = false
    var isUserInTheRoom = true {
        didSet {
            if isUserInTheRoom == false {
                IQKeyboardManager.shared.enable = false
                inputField.isEnabled = false
                inputField.placeholder = "Can't type if user is not in the room"
                
            } else {
                IQKeyboardManager.shared.enable = true
                inputField.isEnabled = true
                inputField.placeholder = " Aa"
            }
        }
    }
    
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
        // scrollToBottom()
        
        // socketIOManager.listenOnLeave()
        updateInCommingMessage()
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
    
    // MARK: - Button Action -
    // Send button clicked
    @objc func sendButtonClicked() {
        guard let text = inputField.text, !text.isEmpty else { return }
        
        viewModel.userAppendMessages(
            inputText: text,
            time: Date().timeIntervalSince1970)
        
        tableView.reloadData()
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
        
        if tableView.numberOfRows(inSection: 0) == 0 {
            return
        }
        
        DispatchQueue.main.async { [self] in
            let indexPath = IndexPath(
                row: tableView.numberOfRows(inSection: 0) - 1,
                section: 0)
            
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    // MARK: - Action for incomming event
    func updateInCommingMessage() {
        
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
//        socketIOManager.recievedUserToken = { userToken in
//            
//            self.presentSimpleAlert(title: "Success", message: "User enter the room", buttonText: "Ok") {
//                self.isUserInTheRoom.toggle()
//            }
//        
//            // Fetch chat history
//            self.chatManager.fetchHistory(userToken: userToken ) { result in
//                switch result {
//                case .success(let history):
//                    print("Successfully fetched history: \(history)")
//                    self.chatProvider.conversationHistory.append(contentsOf: history)
//                    
//                    DispatchQueue.main.async {
//                        self.tableView.reloadData()
//                        self.scrollToBottom()
//                    }
//                    
//                case .failure(let error):
//                    print("Failed fetching history \(error)")
//                }
//            }
//        }
        
        // Handle talk result
//        socketIOManager.recievedTalkResult = { result in
//            switch result {
//                
//            case .success(let successText):
//                print("Look at message" + successText[0])
//                print("Look at time " + successText[1])
//                // self.chatProvider.userAppendMessages(inputText: successText)
//                self.chatProvider.userAppendMessages(inputText: successText[0], time: successText[1])
//                
//                DispatchQueue.main.async { [self] in
//                    tableView.reloadData()
//                    scrollToBottom()
//                }
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
        
        // switchButton.setTitleColor(.hexToUIColor(hex: "3F3A3A"), for: .normal)
        
        sendButton.tintColor = .hexToUIColor(hex: "#3F3A3A")
        
        inputField.textAlignment = .left
        inputField.placeholder = "User not in the room"
        inputField.backgroundColor = .hexToUIColor(hex: "#CCCCCC")
        inputField.setCornerRadius(10)
        
        IQKeyboardManager.shared.enable = false
        inputField.isEnabled = false
        
        tableView.delegate = self
        tableView.dataSource = self
        
        footerView.backgroundColor = .hexToUIColor(hex: "#F5F5F5")
        footerView.setBoarderColor(.hexToUIColor(hex: "#CCCCCC"))
        footerView.setBoarderWidth(1)
        
        sendButton.addTarget(self, action: #selector(sendButtonClicked), for: .touchUpInside)
        
//        kickButton.addTarget(self, action: #selector(kickButtonClicked), for: .touchUpInside)
        
        // Create a UIBarButtonItem with title "Click Me"
//        let kickNavButton = UIBarButtonItem(
//            title: "Kick",
//            style: .plain,
//            target: self,
//            action: #selector(kickButtonClicked))

        // Add the button to the navigation bar on the right side
        // navigationItem.rightBarButtonItem = kickNavButton
        
        // Customize navigation bar
        // UINavigationBar.appearance().backgroundColor = .hexToUIColor(hex: "#3F3A3A")
    }
    
    func setupConstranit() {
        
        sendButton.trailingConstr(to: view.trailingAnchor, -10)
            .centerYConstr(to: footerView.centerYAnchor, 0)
            .widthConstr(50)
            .heightConstr(50)
        
        footerView.leadingConstr(to: view.leadingAnchor, 0)
            .trailingConstr(to: view.trailingAnchor, 10)
            .bottomConstr(to: view.safeAreaLayoutGuide.bottomAnchor, 0)
            .heightConstr(50)
        
        inputField.leadingConstr(to: footerView.trailingAnchor, 10)
            .trailingConstr(to: sendButton.leadingAnchor, -10)
            .bottomConstr(to: footerView.bottomAnchor, -10)
            .topConstr(to: footerView.topAnchor, 10)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: footerView.topAnchor)
        ])
    }
}

// MARK: - Delegate and DataSource method -
extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        MockData.conversationHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userEmail = MockData.conversationHistory[indexPath.row].userEmail
        
        let isUser = userEmail == userManager.currentUser.email ? true: false
        
        switch isUser {
        case true:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ChatRightTableViewCell.reuseIdentifier,
                for: indexPath
            ) as? ChatRightTableViewCell else { return UITableViewCell()}
            
            cell.messageLabel.text =
            MockData.conversationHistory[indexPath.row].content
            
            cell.timeLabel.text =
            MockData.conversationHistory[indexPath.row].sendTime.customFormat()
            
            cell.backgroundColor = .clear
            
            return cell
            
        case false:
            
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ChatLeftTableViewCell.reuseIdentifier,
                for: indexPath
            ) as? ChatLeftTableViewCell else { return UITableViewCell()}
            
            cell.profilePic.image = UIImage(systemName: "person.circle")
            
            cell.messageLabel.text =
            MockData.conversationHistory[indexPath.row].content
            
            cell.timeLabel.text =
            MockData.conversationHistory[indexPath.row].sendTime.customFormat()
            
            cell.backgroundColor = .clear

            return cell
        }
    }
}

// MARK: - Configure title -
//extension ChatViewController {
//    func configureTitle() {
//        titleView.customSetup("客服中心", "PingFangTC-Medium", 18, 0.0, hexColor: "#3F3A3A")
//        titleView.textAlignment = .center
//        titleView.translatesAutoresizingMaskIntoConstraints = false
//        navigationItem.titleView = titleView
//    }
//}

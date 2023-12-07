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
import FirebaseFirestore
import SnapKit

class ChatViewController: UIViewController {
    
    var firebaseManage = FirestoreManager.shared

    var titleView = UILabel()
    
    // TableViews
    var tableView = ChatTableView()
    var sessionsTableView = ExploreTableView()
    
    var viewModel = ChatViewModel()
    var userManager = UserManager.shared
    var currentBundle = ChatBundle(messages: [], participants: [], roomID: "")
    var LRG: ListenerRegistration?
    
    let footerView = UIView()
    var inputField = UITextField()
    
    // Folded view
    var foldedView = UIView()
    var foldedViewLeadingConstraint: NSLayoutConstraint!
    var isFolded = true
    
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
        setupListener()
        
        // Binding for listener
        viewModel.LRG.bind { listenerRegistration in
            self.LRG = listenerRegistration
        }
        
        // Binding for bundle
        viewModel.currentBundle.bind { bundle in
            
            self.currentBundle = bundle
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.scrollToBottom()
            }
        }
    }
    
    // MARK: - ViewDidLoad function -
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
    
    // MARK: - Basic setup -
    func setup() {
        tableView.backgroundColor = .white
        view.backgroundColor = .white
        
        view.addSubviews([tableView, footerView, foldedView])
        footerView.addSubviews([inputField, sendButton])
        
        sendButton.tintColor = .hexToUIColor(hex: "#3F3A3A")
        
        inputField.textAlignment = .left
        inputField.placeholder = "Aa"
        inputField.setCornerRadius(10)
        inputField.backgroundColor = .hexToUIColor(hex: "#CCCCCC")
        inputField.isEnabled = true
        inputField.textColor = .black
        IQKeyboardManager.shared.enable = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        footerView.backgroundColor = .hexToUIColor(hex: "#F5F5F5")
        footerView.setBoarderColor(.lightGray)
        footerView.setBoarderWidth(1.5)
        
        sendButton.addTarget(self, action: #selector(sendButtonClicked), for: .touchUpInside)
        
        // Set initial foled value
        isFolded = true
        
        // Setup fold view appearance
        foldedView.setbackgroundColor(.hexToUIColor(hex: "#FF4E4E"))
            .layer.shadowColor = UIColor.hexToUIColor(hex: "#3F3A3A").cgColor
        foldedView.layer.shadowRadius = 10
        foldedView.setBoarderColor(.hexToUIColor(hex: "#3F3A3A"))
            .setCornerRadius(20)
            .setBoarderWidth(2.5)
            .layer.shadowOpacity = 0.6
        
        // Add gesture recognition
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        // Create the chatroom
        // viewModel.createChatRoom()
    }
    
    // MARK: - Handle user leave event -
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
        
        foldedView.snp.makeConstraints { make in
            make.top.equalTo(view.snp_topMargin)
            make.width.equalTo(200)
            make.bottom.equalTo(600)
        }
        
        // Set the initial position off-screen
        foldedViewLeadingConstraint = foldedView.leadingAnchor.constraint(
            equalTo: view.leadingAnchor,
            constant: -200)
        foldedViewLeadingConstraint.isActive = true
    }
    
    // MARK: - Additional method -
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        
        if gesture.direction == .right {
            
            animateConstraint(newConstant: 0)
            
        } else if gesture.direction == .left {
            
            animateConstraint(newConstant: -200)
        }
    }
    
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
    
    func animateConstraint(newConstant: CGFloat) {
        // Calculate the new constant for the leading constraint
        let newConstant: CGFloat = newConstant
        
        // Animate the constraint change
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.3) {
                self.foldedViewLeadingConstraint.constant = newConstant
                self.view.layoutIfNeeded()
            }
    }
    
    // Setting up listener
    func setupListener() {

        // viewModel.setupChatListener(docPath: currentBundle.roomID)
        viewModel.setupChatListener(docPath: "chatBundles/iyPYCGGIkx1CWv6Pki1O")
        
        DispatchQueue.main.async { [self] in
            tableView.reloadData()
            scrollToBottom()
        }
    }
    
    func configureChatCell(_ cell: UITableViewCell, with message: ChatMessage, isCurrentUser: Bool) {
        // Common setup for all cells
        cell.backgroundColor = .clear

        if let chatCell = cell as? ChatRightTableViewCell, isCurrentUser {
            // Configure right cell
            chatCell.messageLabel.text = message.content
            chatCell.timeLabel.text = message.sendTime.customFormat()
        } else if let chatCell = cell as? ChatLeftTableViewCell {
            // Configure left cell
            chatCell.profilePic.image = UIImage(systemName: "person.circle")
            chatCell.messageLabel.text = message.content
            chatCell.timeLabel.text = message.sendTime.customFormat()
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
        let message = currentBundle.messages[indexPath.row]
        let isUser = message.userEmail == userManager.currentUser.email

        let cellIdentifier = isUser ? ChatRightTableViewCell.reuseIdentifier : ChatLeftTableViewCell.reuseIdentifier

        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        configureChatCell(cell, with: message, isCurrentUser: isUser)

        return cell
    }
}

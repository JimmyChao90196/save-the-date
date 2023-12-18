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
import Lottie

class ChatViewController: UIViewController {
    
    var firebaseManage = FirestoreManager.shared
    
    var titleView = UILabel()
    
    // Profile images
    var profileImages = [String: UIImage?]()
    
    // TableViews
    var tableView = ChatTableView()
    var sessionsTableView = SessionTableView()
    
    // View Model
    var count = 0
    var viewModel = ChatViewModel()
    var userManager = UserManager.shared
    var currentBundle = ChatBundle(messages: [], participants: [], roomID: "")
    var sessionPackages = [Package]()
    var LRG: ListenerRegistration?
    
    let footerView = UIView()
    var inputField = UITextField()
    
    // Animation view
    var menuHintAnimationView = LottieAnimationView()
    var chatBGAnimationView = LottieAnimationView()
    
    // Folded view
    var foldedView = UIView()
    var foldedViewLeadingConstraint: NSLayoutConstraint!
    var isFold = true
    var menuTitle = UILabel()
    var topDivider = UIView()
    var menuTitleDividerLeft = UIView()
    var menuTitleDividerRight = UIView()
    
    // UI
    var sessionNameTitle: UILabel = {
        
        let label = UILabel()
        
        label.setChalkFont(20)
            .setTextColor(.white)
            .setbackgroundColor(.standardColorCyan)
            .setCornerRadius(10)
            .setBoarderColor(.black)
            .setBoarderWidth(2.5)
            .text = "testing"
            
        label.isHidden = true
        label.clipsToBounds = true
        label.textAlignment = .center
        
        return label
    }()
    
    // Nav item
    lazy var menuButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(systemName: "menucard"),
            style: .plain,
            target: self,
            action: #selector(menuButtonPressed))
        
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
        
        // Bind for folding
        viewModel.isFold.bind { isFold in
            if isFold == true {
                self.animateConstraint(newConstant: -200)
            } else {
                self.animateConstraint(newConstant: 0)
            }
        }
        
        // Binding for fetching user
        viewModel.currentUser.bind { currentUser in
            
            if self.count >= 1 {
                self.userManager.currentUser = currentUser
                self.viewModel.fetchSessionPackages()
            }
            
            self.count += 1
        }
        
        // Bind for session packages
        viewModel.sessionPackages.bind { packages in
            self.sessionPackages = packages
            
            DispatchQueue.main.async {
                self.sessionsTableView.reloadData()
            }
        }
        
        // Binding for listener
        viewModel.LRG.bind { listenerRegistration in
            self.LRG = listenerRegistration
        }
        
        // Bind for profile photos
        viewModel.profileImages.bind { profileImages in
            
            self.profileImages = profileImages
            
            self.tableView.reloadData()
        }
        
        // Binding for bundle
        viewModel.currentBundle.bind { bundle in
            
            var copyBundle = bundle
            copyBundle.messages.insert(
                ChatMessage(
                    sendTime: TimeInterval(),
                    userId: self.userManager.currentUser.uid,
                    userName: self.userManager.currentUser.name,
                    content: "placeholder"),
                at: 0)
            
            self.currentBundle = copyBundle
            
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
        
        viewModel.fetchCurrentUser(self.userManager.currentUser.uid)
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = false
        setNeedsStatusBarAppearanceUpdate()
    }
    
// MARK: - Setup -
    func setup() {
        
        // Seting animation view
        chatBGAnimationView = LottieAnimationView(name: "ChatBG")
        chatBGAnimationView.isUserInteractionEnabled = false
        chatBGAnimationView.contentMode = .scaleAspectFill
        chatBGAnimationView.play()
        chatBGAnimationView.loopMode = .loop
        
        menuHintAnimationView = LottieAnimationView(name: "MenuHint")
        menuHintAnimationView.isUserInteractionEnabled = false
        menuHintAnimationView.play()
        menuHintAnimationView.loopMode = .loop
        
        tableView.backgroundColor = .clear
        // Setup menu title
        menuTitle.setChalkFont(21)
            .setTextColor(.black)
            .text = "Sessions"
        
        menuTitleDividerLeft.setbackgroundColor(.black)
        menuTitleDividerRight.setbackgroundColor(.black)
        topDivider.setbackgroundColor(.black)
        
        // Setup session table view
        sessionsTableView.setbackgroundColor(.clear)
            .setCornerRadius(20)
            .setBoarderWidth(2)
            .setBoarderColor(.black)
        
        sessionsTableView.register(
            SessionTableViewCell.self,
            forCellReuseIdentifier: SessionTableViewCell.reuseIdentifier)
        
        view.backgroundColor = .customLightGrey
        tableView.backgroundColor = .clear
        
        view.addSubviews([
            chatBGAnimationView,
            menuHintAnimationView,
            tableView,
            footerView,
            topDivider,
            sessionNameTitle,
            foldedView
        ])
        
        foldedView.addSubviews([
            sessionsTableView,
            menuTitle,
            menuTitleDividerLeft,
            menuTitleDividerRight])
        
        footerView.addSubviews([
            inputField,
            sendButton])
        
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
        sessionsTableView.delegate = self
        sessionsTableView.dataSource = self
        
        footerView.backgroundColor = .hexToUIColor(hex: "#F5F5F5")
        footerView.setBoarderColor(.lightGray)
        footerView.setBoarderWidth(1.5)
        
        sendButton.addTarget(self, action: #selector(sendButtonClicked), for: .touchUpInside)
        
        // Setup nav item
        self.navigationItem.leftBarButtonItem = menuButton
        
        // Set initial foled value
        isFold = true
        
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
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(sendDemoMessage(_:)))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(sendDemoMessage(_:)))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
        
        // MARK: - Fetch session packages at the first place
        viewModel.fetchSessionPackages()
    }
    
    // MARK: - Handle user leave event -
    func setupConstranit() {
        
        // Set title
        sessionNameTitle.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.snp.topMargin).offset(10)
            make.width.equalTo(200)
            make.height.equalTo(40)
        }
        
        chatBGAnimationView.snp.makeConstraints { make in
            make.edges.equalTo(tableView)
        }
        
        menuHintAnimationView.snp.makeConstraints { make in
            make.edges.equalTo(tableView)
        }
        
        // set top divider
        topDivider.snp.makeConstraints { make in
            make.top.equalTo(view.snp.topMargin)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(2)
        }
        
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
        
        menuTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }
        
        menuTitleDividerLeft.snp.makeConstraints { make in
            make.trailing.equalTo(menuTitle.snp.leading).offset(-10)
            make.centerY.equalTo(menuTitle.snp.centerY)
            make.height.equalTo(2)
            make.width.equalTo(40)
        }
        
        menuTitleDividerRight.snp.makeConstraints { make in
            make.leading.equalTo(menuTitle.snp.trailing).offset(10)
            make.centerY.equalTo(menuTitle.snp.centerY)
            make.height.equalTo(2)
            make.width.equalTo(40)
        }
        
        sessionsTableView.snp.makeConstraints { make in
            make.top.equalTo(menuTitle.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        foldedView.snp.makeConstraints { make in
            make.top.equalTo(view.snp_topMargin)
            make.width.equalTo(200)
            make.bottom.equalTo(view.snp.bottomMargin)
        }
        
        // Set the initial position off-screen
        foldedViewLeadingConstraint = foldedView.leadingAnchor.constraint(
            equalTo: view.leadingAnchor,
            constant: -200)
        foldedViewLeadingConstraint.isActive = true
    }
    
    // MARK: - Additional method -
    
    // Menu button
    @objc func menuButtonPressed() {
        viewModel.animateMenu(nil)
        
        DispatchQueue.main.async {
            self.menuHintAnimationView.isHidden = true
        }
    }
    
    // swipe action
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        viewModel.animateMenu(gesture)
    }
    
    @objc func sendDemoMessage(_ gesture: UISwipeGestureRecognizer) {
        viewModel.sendDemoMessage(gesture, roomID: currentBundle.roomID)
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
    func setupListener(bundleID: String) {
        
        viewModel.setupChatListener(docPath: bundleID)
        
        DispatchQueue.main.async { [self] in
            tableView.reloadData()
            scrollToBottom()
        }
    }
    // MARK: - Cell Configuration -
    func configureChatCell(
        _ cell: UITableViewCell,
        with message: ChatMessage,
        isCurrentUser: Bool,
        photoURL: String,
        userId: String
    ) {
            // Common setup for all cells
            cell.backgroundColor = .clear
            
            if let chatCell = cell as? ChatRightTableViewCell, isCurrentUser {
                // Configure right cell
                chatCell.messageLabel.text = message.content
                chatCell.timeLabel.text = message.sendTime.customFormat()
            } else if let chatCell = cell as? ChatLeftTableViewCell {
                // Configure left cell
                viewModel.fetchImage(otherUserId: userId, photoURL: photoURL)
                chatCell.profilePic.contentMode = .scaleAspectFill
                chatCell.profilePic.image = profileImages[userId] ??
                UIImage(systemName: "person.circle")
                chatCell.profilePic.tintColor = .customUltraGrey
                
                chatCell.messageLabel.text = message.content
                chatCell.timeLabel.text = message.sendTime.customFormat()
            }
        }
    
    func configureSessionCell(
        _ cell: UITableViewCell,
        intputText text: String) {
            
            if let sessionCell = cell as? SessionTableViewCell {
                sessionCell.packageTitleLabel.text = text
            }
        }
}

// MARK: - Delegate and DataSource method -
extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch tableView {
            
        case sessionsTableView:
            
            // Remove previous LRG
            if LRG != nil {
                LRG?.remove()
            }
            
            // Find docpath
            let chatDocPath = self.sessionPackages[indexPath.row].chatDocPath
            setupListener(bundleID: chatDocPath)
            
            tableView.deselectRow(at: indexPath, animated: true)
            sessionNameTitle.text = self.sessionPackages[indexPath.row].info.title
            sessionNameTitle.isHidden = false
            animateConstraint(newConstant: -200)
            
        default:
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch tableView {
        case sessionsTableView: self.sessionPackages.count
        default: currentBundle.messages.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch tableView {
        case sessionsTableView:
            let cellIdentifier = SessionTableViewCell.reuseIdentifier
            let cell = tableView.dequeueReusableCell(
                withIdentifier: cellIdentifier,
                for: indexPath)
            
            let title = self.sessionPackages[indexPath.row].info.title
            configureSessionCell(cell, intputText: title)
            
            return cell
            
        default:
            
            let message = currentBundle.messages[indexPath.row]
            let isUser = message.userId == userManager.currentUser.uid
            let uid = message.userId
            let photoURL = message.photoURL
            
            let cellIdentifier = isUser ?
            ChatRightTableViewCell.reuseIdentifier :
            ChatLeftTableViewCell.reuseIdentifier
            
            let cell = tableView.dequeueReusableCell(
                withIdentifier: cellIdentifier,
                for: indexPath)
            cell.selectionStyle = .none
            
            // Move down cell a bit
            if indexPath.row == 0 {
                cell.isHidden = true
            } else {
                cell.isHidden = false
            }
            
            configureChatCell(
                cell,
                with: message,
                isCurrentUser: isUser,
                photoURL: photoURL,
                userId: uid
            )

            return cell
        }
    }
}

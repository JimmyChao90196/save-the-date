//
//  ChatProvider.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/12/7.
//

import Foundation
import UIKit
import FirebaseFirestore

class ChatViewModel {
    
    let firestoreManager = FirestoreManager.shared
    let userManager = UserManager.shared
    
    var LRG = Box<ListenerRegistration?>(nil)
    var sessionPackages = Box<[Package]>([])
    var currentBundle = Box(ChatBundle(
        messages: [],
        participants: [],
        roomID: ""))
    
    // Chat listener
    func setupChatListener(docPath: String) {
        let LRG = firestoreManager.chatListener(
            docPath: docPath) { bundle in
                self.currentBundle.value = bundle
            }
        
        self.LRG.value = LRG
    }
    
    // Create chatroom
    func createChatRoom(
        with participants: [String] = []) {
        firestoreManager.createChatRoom(
            with: participants) { result in
                switch result {
                case .success(let newBundle):
                    self.currentBundle.value = newBundle
                    
                case .failure(let error):
                    print("Couldn't fetch any chat history \(error)")
                }
            }
    }
    
    // Send message
    func sendMessage(
        currentUser: User,
        inputText: String,
        docPath: String,
        time: TimeInterval = Date().timeIntervalSince1970) {
            
            // Format the message
            let messageToSend = ChatMessage(
                sendTime: Date().timeIntervalSince1970,
                userEmail: currentUser.email,
                userName: currentUser.name,
                content: inputText)
            
            // Apply message locally first
            currentBundle.value.messages.append(messageToSend)
            
            firestoreManager.sendMessage(
                message: messageToSend,
                docPath: docPath) { result in
                    switch result {
                    case .success(let fetchedMessages):
                        print("These are the latest messages: \(fetchedMessages)")
                        self.currentBundle.value.messages = fetchedMessages
                        
                    case .failure(let error):
                        print("Fail to send the message: \(error)")
                    }
                }
        }
    
    // Fetch sessionPackages
    func fetchSessionPackages() {
            
        let paths = userManager.currentUser.sessionPackages
        
        print(paths)
            Task {
                do {
                    let fetchedPackages = try await firestoreManager.fetchPackages(withIDs: paths)
                    self.sessionPackages.value = fetchedPackages
                } catch(let error) {
                    print(error)
                }
            }
        }
}

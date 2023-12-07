//
//  ChatProvider.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/12/7.
//

import Foundation
import UIKit

class ChatViewModel {
    
    let firestoreManager = FirestoreManager.shared
    
    var currentBundle = Box(ChatBundle(
        messages: [],
        participants: [],
        roomID: ""))
    
    // Create chatroom
    func createChatRoom(
        with participants: [String] = ["myname90196@gmail.com",
                                       "40548154@gm.nfu.edu.tw"]) {
        firestoreManager.createChatRoom(
            with: participants) { result in
                switch result {
                case .success(let newBundle):
                    self.currentBundle.value = newBundle
                    
                case .failure(let error):
                    print(error)
                }
            }
    }
    
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
}

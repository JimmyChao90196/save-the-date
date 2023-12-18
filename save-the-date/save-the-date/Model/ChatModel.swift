//
//  ChatModel.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/12/6.
//

import Foundation

// Define a struct to represent the message.
struct ChatMessage: Codable {
    let sendTime: TimeInterval
    let userId: String
    let userName: String
    let content: String
    let photoURL: String
    
    init(sendTime: TimeInterval,
         userId: String,
         userName: String,
         content: String,
         photoURL: String = "") {
        
        self.sendTime = sendTime
        self.userId = userId
        self.userName = userName
        self.content = content
        self.photoURL = photoURL
    }
    
}

struct ChatBundle: Codable {
    var messages: [ChatMessage]
    var participants: [String]
    var roomID: String
}

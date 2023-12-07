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
    let userEmail: String
    let userName: String
    let content: String
}

// Mock data

struct MockData {
    
   static let conversationHistory: [ChatMessage] = [
        ChatMessage(
            sendTime: 1670000300,
            userEmail: "myname90196@gmail.com",
            userName: "Jimmy chao",
            content: "Hey 據趙, are you free this weekend?"),
        
        ChatMessage(
            sendTime: 1670000350,
            userEmail: "40548154@gm.nfu.edu.tw",
            userName: "據趙",
            content: "Hi Jimmy! Yeah, I'm free. What's up?"),
        
        ChatMessage(
            sendTime: 1670000400,
            userEmail: "myname90196@gmail.com",
            userName: "Jimmy chao",
            content: "Thinking of going hiking. Interested in joining?"),
        
        ChatMessage(
            sendTime: 1670000450,
            userEmail: "40548154@gm.nfu.edu.tw",
            userName: "據趙",
            content: "That sounds fun! Which trail were you thinking?"),
        
        ChatMessage(
            sendTime: 1670000500,
            userEmail: "myname90196@gmail.com",
            userName: "Jimmy chao",
            content: "Maybe the Green Mountain trail. It's got great views this time of year."),
        ChatMessage(
            sendTime: 1670000550,
            userEmail: "40548154@gm.nfu.edu.tw",
            userName: "據趙",
            content: "Sounds good. Let's do it! What time shall we meet?"),
        
        ChatMessage(
            sendTime: 1670000600,
            userEmail: "myname90196@gmail.com",
            userName: "Jimmy chao",
            content: "How about 9 AM at the trailhead?"),
        
        ChatMessage(
            sendTime: 1670000650,
            userEmail: "40548154@gm.nfu.edu.tw",
            userName: "據趙",
            content: "Perfect! See you there")
    ]
}

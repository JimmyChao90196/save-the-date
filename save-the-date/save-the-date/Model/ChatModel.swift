//
//  ChatModel.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/12/6.
//

import Foundation

// Define a struct to represent the message.
struct ChatMessage: Codable {
    let sendTime: String
    let userEmail: String
    let userName: String
    let content: String
}

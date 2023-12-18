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
    
    var isFold = Box(true)
    var currentUser = Box(User())
    var profileImages = Box<[String: UIImage?]>([:])
    var LRG = Box<ListenerRegistration?>(nil)
    var sessionPackages = Box<[Package]>([])
    var currentBundle = Box(ChatBundle(
        messages: [],
        participants: [],
        roomID: ""))
    
    // Send demo message
    func sendDemoMessage(
        _ gesture: UISwipeGestureRecognizer?,
        roomID: String
    ) {
        
        guard let gesture else { return }
        
        // If it is swiped
        if gesture.direction == .up {
            sendMessage(currentUser: userManager.currentUser, inputText: "Very good idea", docPath: roomID)
            
        } else if gesture.direction == .down {
            sendMessage(currentUser: userManager.currentUser, inputText: "Count me in please", docPath: roomID)
        }
    }
    
    // Animate menu
    func animateMenu( _ gesture: UISwipeGestureRecognizer? ) {
        
        guard let gesture else {
            isFold.value.toggle()
            return
        }
        
        // If it is swiped
        if gesture.direction == .right {
            isFold.value = false
        } else if gesture.direction == .left {
            isFold.value = true
        }
    }
    
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
                userId: currentUser.uid,
                userName: currentUser.name,
                content: inputText,
                photoURL: currentUser.photoURL
            )
            
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
                } catch {
                    print(error)
                }
            }
        }
    
    // Fetch user
    func fetchCurrentUser( _ userId: String) {

        Task {
            do {
                let user = try await firestoreManager.fetchUser( userId )
                self.currentUser.value = user
                
            } catch {
            
                print(error)
            }
        }
    }
    
    // Fetch images
    func fetchImage(otherUserId ouid: String, photoURL urlString: String) {
        
        if profileImages.value[ouid] != nil { return }
        
        userManager.downloadImage(urlString: urlString) { result in
            switch result {
            case .success(let fetchedImage):
                self.profileImages.value[ouid] = fetchedImage
                
            case .failure(let error):
                print("faild to fetch the photos \(error)")
            }
        }
    }
}

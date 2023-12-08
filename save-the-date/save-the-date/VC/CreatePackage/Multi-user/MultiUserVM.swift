//
//  MultiUserVM.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/12/8.
//

import Foundation
import UIKit
import FirebaseFirestore

class MultiUserViewModel {
    
    let firestoreManager = FirestoreManager.shared
    let userManager = UserManager.shared
    
    var currentChatBundle = Box<ChatBundle>(
        ChatBundle(messages: [],
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
                    
                    print("Successfully created a new chat bundle: \(newBundle)")
                    self.currentChatBundle.value = newBundle
                    
                case .failure(let error):
                    print(error)
                }
            }
    }
    
    // Add people to the chatroom
    func updateChatRoom( newEmail newPerson: String, docPath: String ) {
        
        firestoreManager.updateChatRoom(
            newPerson: newPerson,
            docPath: docPath,
            perform: .add) { result in
                switch result {
                case .success(let text):
                    print("\(text)!! Successfully update the participant")
                case .failure(let error):
                    print("Error updating participants: \(error)")
                }
            }
    }
    
    // Update package
    func updatePackage(
        pathToUpdate path: String,
        packageToUpdate docPath: String
    ) {
        firestoreManager.updatePackage(
            infoToUpdate: path,
            docPath: docPath,
            toPath: "chatDocPath",
            perform: .add) {
                print("Successfully append chatDocPath to session package")
            }
    }
}

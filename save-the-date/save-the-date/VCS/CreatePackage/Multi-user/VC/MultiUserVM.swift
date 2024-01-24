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
    
    func createChatRoom(
        with participants: [String] = ["participant1",
                                       "participant2"]) {
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
    func updateChatRoom( newId: String, docPath: String ) {
        
        firestoreManager.updateChatRoom(
            newId: newId,
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
    
    func updatePackageAndUserInfo(sessionId: String, name: String, uid: String) {
        // Add user name and userId to package
        self.firestoreManager.updatePackage(
            infoToUpdate: name,
            docPath: sessionId,
            toPath: .author,
            perform: .add) {}
        
        self.firestoreManager.updatePackage(
            infoToUpdate: uid,
            docPath: sessionId,
            toPath: .authorId,
            perform: .add) {}
        
        self.firestoreManager.updateUserPackages(
            userId: uid,
            packageType: .sessionColl,
            docPath: sessionId,
            perform: .add) { }
    }
    
    func fetchPackages(id: String) async -> Package? {
        
        let sessionPackage = try? await self.firestoreManager.fetchPackage(withID: id)
        return sessionPackage
    }
}

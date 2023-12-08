//
//  FirestoreManager+Chat.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/12/6.
//

import Foundation
import FirebaseFirestore
import UIKit

extension FirestoreManager {
    
    // MARK: - Create chatroom -
    func createChatRoom(
        with participants: [String],
        completion: @escaping (Result<ChatBundle, Error>) -> Void) {
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            
            do {
                // Create a document reference first
                let newDocumentRef = fdb.collection("chatBundles").document()
                // let newDocumentID = newDocumentRef.documentID
                let newChatBundle = ChatBundle(
                    messages: [],
                    participants: participants,
                    roomID: newDocumentRef.path)
                
                // Encode object into JSON and converted it to a dictionary
                let jsonData = try encoder.encode(newChatBundle)
                let dictionary = try jsonData.toDictionary()
                
                // Upload the JSON dictionary to Firestore
                newDocumentRef.setData(dictionary) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(newChatBundle))
                    }
                }
            } catch {
                // Handle encoding errors
                completion(.failure(error))
            }
        }
    
    // MARK: - Update chatroom
    func updateChatRoom(
        newPerson: String,
        docPath: String,
        perform operation: PackageOperation,
        completion: ((Result<String, Error>) -> Void)? ) {
            
            let chatRef = fdb.document(docPath)
            let fieldPath = "participants"
            
            var fieldOperation = FieldValue.arrayUnion([newPerson])
            switch operation {
            case .add:
                fieldOperation = FieldValue.arrayUnion([newPerson])
            case .remove:
                fieldOperation = FieldValue.arrayRemove([newPerson])
            }
            
            chatRef.updateData([fieldPath: fieldOperation ]) { error in
                if let error = error {
                    completion?(.failure(error))
                } else {
                    completion?(.success("Success"))
                }
            }
        }
    
    // MARK: - Upload messages -
    func sendMessage(
        message: ChatMessage,
        docPath: String,
        completion: @escaping (Result<[ChatMessage], Error>) -> Void
    ) {
        let userRef = fdb.document(docPath)
        var latestMessages = [ChatMessage]()
        
        // Start a Firestore transaction
        fdb.runTransaction({ (transaction, errorPointer) -> Any? in
            
            let userDocument: DocumentSnapshot
            do {
                try userDocument = transaction.getDocument(userRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            // Convert Firestore data to JSON and then deserialize
            guard let messageData = userDocument.data(),
                  let jsonData = try? JSONSerialization.data(withJSONObject: messageData, options: []),
                  var chatBundle = try? JSONDecoder().decode(ChatBundle.self, from: jsonData) else {
                let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Unable to deserialize package data."
                ])
                errorPointer?.pointee = error
                return nil
            }
            
            var newMessages = chatBundle.messages
            newMessages.append(message)
            latestMessages = newMessages
            
            // Prepare the update
            transaction.updateData(
                ["messages": newMessages.map({ try? $0.toDictionary() })],
                forDocument: userRef)
            
            // Return the new message as the transaction result
            return message
        }, completion: { (transactionResult, error) in
            if let error = error {
                completion(.failure(error))
            } else if let message = transactionResult as? ChatMessage {
                completion(.success(latestMessages))
            } else {
                completion(.failure(NSError(
                    domain: "ChatError",
                    code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"])))
            }
        })
    }
    
    // MARK: - Chat listener -
    
    func chatListener(
        docPath: String,
        onChange: @escaping (ChatBundle) -> Void) -> ListenerRegistration? {
            
            let chatDocument = fdb.document(docPath)
            
            let listenerRigsteration = chatDocument.addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                guard let data = document.data() else {
                    print("Document data was empty.")
                    return
                }
                do {
                    let chatBundle = try Firestore.Decoder().decode(ChatBundle.self, from: data)
                    
                    onChange(chatBundle)
                    
                } catch let error {
                    print("Error decoding bundle: \(error)")
                }
            }
            
            return listenerRigsteration
        }
}

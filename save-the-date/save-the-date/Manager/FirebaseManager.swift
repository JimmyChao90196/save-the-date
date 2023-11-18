//
//  FirebaseManager.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/18.
//

import Foundation
import FirebaseFirestore
import UIKit

enum FirestoreError: Error{
    case userNotFound
    case userAlreadyExist
}

class FirestoreManager {
    
    static let shared = FirestoreManager()
    
    let db =  Firestore.firestore()
    
    var collectionId = "Packages"
    
    var articleRef: DocumentReference {
        db.collection("Packages").document()
    }
    
    var userRef: DocumentReference {
        db.collection("Users").document()
    }
    
    func addUser(article: Article, completion: @escaping () -> Void) {
        // Get a reference to the Firestore database
        let db = Firestore.firestore()
        
        // Reference to the articles collection
        let articles = db.collection("articles")
        
        // Document reference with auto-generated ID
        let document = articles.document()

        // Prepare data to be added
        let data: [String: Any] = [
            "author": article.author,
            "title": article.title,
            "content": article.content,
            "createdTime": article.createdTime,
            "id": document.documentID,
            "category": article.category
        ]

        // Adding data to Firestore
        document.setData(data) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added with ID: \(document.documentID)")
                completion()
            }
        }
    }
    
}

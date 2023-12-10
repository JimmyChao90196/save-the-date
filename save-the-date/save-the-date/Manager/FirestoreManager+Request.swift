//
//  FirestoreManager+Request.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/12/10.
//

import Foundation
import FirebaseFirestore
import UIKit

extension FirestoreManager {
    
    // MARK: - SubmitReport -
    func submitRequest(
        targetDocPath docPath : String,
        _ requestType: RequestType,
        completion: @escaping (Result<String, Error>) -> Void) {
            
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let newRef = fdb.collection("packageRequests").document()
            let newID = newRef.documentID
            
            let newRequest = PackageRequest(
                target: docPath,
                type: requestType.rawValue,
                reason: "Too weird",
                requestID: newRef.path)
            
            // Encode your user object into JSON
            let jsonData = try encoder.encode(newRequest)
            
            // Convert JSON data to a dictionary
            let dictionary = try jsonData.toDictionary()
            
            // Upload the JSON dictionary to Firestore
            newRef.setData(dictionary) { error in
                if let error = error {
                    print("uploaded failed: \(error)")
                    completion(.failure(error))
                } else {
                    completion(.success(newID))
                }
            }
        } catch {
            // Handle encoding errors
            completion(.failure(error))
        }
    }
}

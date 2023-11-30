//
//  FirestoreManager+Search.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/30.
//

import Foundation

extension FirestoreManager {
    
    func searchPackages(by text: String, completion: @escaping (Result<[Package], Error>) -> Void) {
        let packagesCollection = fdb.collection("publishedPackages")

        // Create a range for the search string
        let queryStart = text
        let queryEnd = text + "\u{f8ff}"

        packagesCollection
            .whereField("info.title", isGreaterThanOrEqualTo: queryStart)
            .whereField("info.title", isLessThanOrEqualTo: queryEnd)
            .getDocuments { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    completion(.failure(err))
                } else {
                    var packages = [Package]()
                    for document in querySnapshot!.documents {
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: document.data(), options: [])
                            let package = try JSONDecoder().decode(Package.self, from: jsonData)
                            packages.append(package)
                        } catch {
                            print("Error decoding package: \(error)")
                            completion(.failure(error))
                            return
                        }
                    }
                    completion(.success(packages))
                }
            }
    }

}

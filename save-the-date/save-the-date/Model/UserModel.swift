//
//  UserModel.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/18.
//

import Foundation
import UIKit

struct User {
    var name: String
    var email: String
    
    var draftPackage: [String]
    var favoritetPackage: [String]
    var forkedPackage: [String]
    var publishedPackage: [String]
    var privatePackage: [String]
    
    init(name: String = "Jimmy Chao",
         email: String = "jimmy@gmail.com",
         draftPackage: [String] = [],
         favoritetPackage: [String] = [],
         forkedPackage: [String] = [],
         publishedPackage: [String] = [],
         privatePackage: [String] = []) {
        
        self.name = name
        self.email = email
        self.draftPackage = draftPackage
        self.favoritetPackage = favoritetPackage
        self.forkedPackage = forkedPackage
        self.publishedPackage = publishedPackage
        self.privatePackage = privatePackage
    }
    
    var dictionary: [String: Any] {
        return [
            "name": name,
            "email": email,
            "draftPackages": draftPackage,
            "favoritePackages": favoritetPackage,
            "forkedPackages": forkedPackage,
            "publishedPackages": publishedPackage,
            "privatePackages": privatePackage
        ]
    }
}

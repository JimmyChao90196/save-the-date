//
//  UserModel.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/18.
//

import Foundation
import UIKit

struct User: Codable {
    var name: String
    var email: String
    
    var draftPackages: [String]
    var favoritePackages: [String]
    var forkedPackages: [String]
    var publishedPackages: [String]
    var privatePackages: [String]
    
    init(name: String = "Jimmy Chao",
         email: String = "jimmy@gmail.com",
         draftPackages: [String] = [],
         favoritePackages: [String] = [],
         forkedPackages: [String] = [],
         publishedPackages: [String] = [],
         privatePackages: [String] = []) {
        
        self.name = name
        self.email = email
        self.draftPackages = draftPackages
        self.favoritePackages = favoritePackages
        self.forkedPackages = forkedPackages
        self.publishedPackages = publishedPackages
        self.privatePackages = privatePackages
    }
}

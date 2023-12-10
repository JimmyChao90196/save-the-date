//
//  RequestModel.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/12/10.
//

import Foundation
import FirebaseFirestoreSwift
import UIKit

struct PackageRequest: Encodable, Decodable {
    var target: String
    var type: String
    var reason: String
    var requestID: String
}

enum RequestType: String {
    case report
    case restrict
    case block
}


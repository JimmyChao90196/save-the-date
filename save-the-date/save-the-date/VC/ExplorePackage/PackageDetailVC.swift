//
//  PackageDetailVC.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/18.
//

import Foundation
import UIKit

class PackageDetailViewController: PackageBaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem?.isHidden = true
        navigationItem.rightBarButtonItem?.isHidden = true
    }
}

// MARK: - Delegate and dataSource method
extension PackageDetailViewController {
    
}

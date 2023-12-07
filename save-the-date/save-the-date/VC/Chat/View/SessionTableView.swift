//
//  SessionTableView.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/12/7.
//

import Foundation
import UIKit

class SessionTableView: UITableView {

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupTableView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.register(SessionTableViewCell.self, forCellReuseIdentifier: SessionTableViewCell.reuseIdentifier)
        
        // Self sizing row height
        self.rowHeight = UITableView.automaticDimension
        self.estimatedRowHeight = 150
        self.separatorStyle = .none
    }
}

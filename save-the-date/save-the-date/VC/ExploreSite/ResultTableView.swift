//
//  SeachResultTableView.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/16.
//

import Foundation
import UIKit

class ResultTableView: UITableView {

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupTableView() {
        // Self sizing row height
        self.register(ResultTableViewCell.self, forCellReuseIdentifier: ResultTableViewCell.reuseIdentifier)
        self.rowHeight = UITableView.automaticDimension
        self.estimatedRowHeight = 150
        self.separatorStyle = .none
    }
}

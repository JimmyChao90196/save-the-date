//
//  FriendTableView.swift
//  FireBaseGroup2_iOS
//
//  Created by JimmyChao on 2023/10/24.
//

import UIKit

class ModuleTableView: UITableView {

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        self.register(DayHeaderView.self, forHeaderFooterViewReuseIdentifier: DayHeaderView.reuseIdentifier)
        
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupTableView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.register(ModuleTableViewCell.self, forCellReuseIdentifier: ModuleTableViewCell.reuseIdentifier )
        
        // Self sizing row height
        self.rowHeight = UITableView.automaticDimension
        self.estimatedSectionHeaderHeight = UITableView.automaticDimension
        self.sectionHeaderHeight = UITableView.automaticDimension
        self.contentInsetAdjustmentBehavior = .never
        self.estimatedSectionHeaderHeight = 50
        self.estimatedRowHeight = 150
        self.separatorStyle = .none
    }
}

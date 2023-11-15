//
//  FriendTableView.swift
//  FireBaseGroup2_iOS
//
//  Created by JimmyChao on 2023/10/24.
//

import UIKit

class NumberTableView: UITableView {


    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setupTableView()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    func setupTableView(){
        self.translatesAutoresizingMaskIntoConstraints = false
        self.register(NumberTableViewCell.self, forCellReuseIdentifier: NumberTableViewCell.reuseIdentifier )
        
    }
    
}

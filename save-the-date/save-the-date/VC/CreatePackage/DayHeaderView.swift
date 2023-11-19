//
//  DayHeaderView.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/19.
//

import Foundation
import UIKit
import SnapKit

class DayHeaderView: UIView {
    
    var onAddModulePressed: ((Int) -> Void)?
    
    let titleLabel = UILabel()
    let addModuleButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        button.backgroundColor = .blue
        button.setImage(.add, for: .normal)
        
        return button
    }()
    
    var section: Int = 0 {
        didSet {
            addModuleButton.tag = section
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setupConstranit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        addSubviews([titleLabel, addModuleButton])
        titleLabel.textAlignment = .center
        addModuleButton.addTarget(
            self,
            action: #selector(addModuleButtonPressed),
            for: .touchUpInside)
    }
    
    private func setupConstranit() {
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }
        addModuleButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.trailing.equalToSuperview().offset(-20)
        }
    }

    func setDay(_ day: Int) {
        titleLabel.text = "Day \(day)"
    }
    
    // MARK: - Additional function
    @objc func addModuleButtonPressed(sender: UIButton) {
        onAddModulePressed?(sender.tag)
    }
}

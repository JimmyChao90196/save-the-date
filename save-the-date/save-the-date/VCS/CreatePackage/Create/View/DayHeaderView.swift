//
//  DayHeaderView.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/19.
//

import Foundation
import UIKit
import SnapKit

class DayHeaderView: UITableViewHeaderFooterView {
    
    var onAddModulePressed: ((Int) -> Void)?
    static let reuseIdentifier = String(describing: DayHeaderView.self)
    
    var topDivider = UIView()
    var bottomDivider = UIView()
    var sectionBG = UIImageView(image: UIImage(resource: .sectionDot))
    
    let titleLabel = UILabel()
    let addModuleButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        button.setImage(UIImage(resource: .addNewModuleButton), for: .normal)
        button.setCornerRadius(20)
        button.clipsToBounds = true
        button.contentMode = .scaleToFill
        
        return button
    }()
    
    var section: Int = 0 {
        didSet {
            addModuleButton.tag = section
        }
    }

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
        setupConstranit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        self.contentView.backgroundColor = .hexToUIColor(hex: "#87D6DD")
        self.contentView.addSubviews([sectionBG, titleLabel, addModuleButton, topDivider, bottomDivider])
        titleLabel.textAlignment = .center
        titleLabel.setFont(UIFont(name: "ChalkboardSE-Regular", size: 30)!)
            .setTextColor(.hexToUIColor(hex: "#3F3A3A"))
        
        addModuleButton.addTarget(
            self,
            action: #selector(addModuleButtonPressed),
            for: .touchUpInside)
        
        // Setup appearance
        topDivider.setbackgroundColor(.hexToUIColor(hex: "#3F3A3A"))
        bottomDivider.setbackgroundColor(.hexToUIColor(hex: "#3F3A3A"))
        addModuleButton.setBoarderColor(.hexToUIColor(hex: "#3F3A3A"))
            .setBoarderWidth(2.5)
        sectionBG.contentMode = .scaleAspectFill
        sectionBG.clipsToBounds = true
    }
    
    private func setupConstranit() {
        sectionBG.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        bottomDivider.snp.makeConstraints { make in
            make.bottom.equalTo(contentView.snp.bottom)
            make.top.equalTo(contentView.snp.bottom).offset(-3)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        topDivider.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top)
            make.bottom.equalTo(contentView.snp.top).offset(3)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(10)
            make.bottom.equalTo(contentView.snp.bottom).offset(-10)
            make.leading.equalToSuperview().offset(20)
        }
        addModuleButton.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(10)
            make.bottom.equalTo(contentView.snp.bottom).offset(-10)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(40)
            make.width.equalTo(40)
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

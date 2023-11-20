//
//  ExploreTableViewCell.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/18.
//

import UIKit
import SnapKit

class ExploreTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = String(describing: ExploreTableViewCell.self)
    
    let packageTitleLabel = UILabel()
    let packageBG = UIView()
    let heartImageView = UIImageView(image: UIImage(systemName: "heart"))
    var onLike: ((UITableViewCell, Bool) -> Void)?
    var isLike = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addTo()
        setup()
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func addTo() {
        contentView.addSubviews([packageBG])
        packageBG.addSubviews([packageTitleLabel, heartImageView])
    }
    
    private func setup() {
        
        packageBG.setBoarderColor(.hexToUIColor(hex: "#CCCCCC"))
            .setCornerRadius(20)
            .setBoarderWidth(1)
        
        // Set gesture for image
        let tap = UITapGestureRecognizer(target: self, action: #selector(heartTapped))
        heartImageView.isUserInteractionEnabled = true
        heartImageView.addGestureRecognizer(tap)
    }
    
    private func setupConstraint() {
        
        packageTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-20)
            make.centerX.equalToSuperview()
        }
        
        heartImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-20)
        }
        
        packageBG.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(30)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalTo(contentView.snp.bottom).offset(-30)
        }
    }
}

// MARK: - Additional function -
extension ExploreTableViewCell {
    
    @objc func heartTapped() {
        isLike.toggle()
        
        if isLike {
            heartImageView.image = UIImage(systemName: "heart.fill")
        } else {
            heartImageView.image = UIImage(systemName: "heart")
        }
        
        onLike?(self, isLike)
    }
}

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
    let packageAuthor = UILabel()
    let packageBG = UIView()
    let authorPicture = UIImageView(image: UIImage(resource: .redProfile))
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
        packageBG.addSubviews([
            packageTitleLabel,
            heartImageView,
            packageAuthor,
            authorPicture
        ])
    }
    
    private func setup() {
        packageBG.setBoarderColor(.hexToUIColor(hex: "#CCCCCC"))
            .setCornerRadius(20)
            .setBoarderWidth(1)
        
        // Set gesture for image
        let tap = UITapGestureRecognizer(target: self, action: #selector(heartTapped))
        heartImageView.isUserInteractionEnabled = true
        heartImageView.addGestureRecognizer(tap)
        
        // Setup appearance
        authorPicture.clipsToBounds = true
        authorPicture.setCornerRadius(15)
            .setBoarderColor(.hexToUIColor(hex: "#CCCCCC"))
            .setBoarderWidth(2.0)
            .contentMode = .scaleAspectFit
    }
    
    private func setupConstraint() {
        
        authorPicture.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(50)
            make.width.equalTo(50)
        }
        
        packageAuthor.snp.makeConstraints { make in
            make.top.equalTo(packageTitleLabel.snp.bottom).offset(5)
            make.bottom.equalToSuperview().offset(-10)
            make.leading.equalTo(authorPicture.snp.trailing).offset(10)
        }
        
        packageTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalTo(authorPicture.snp.trailing).offset(10)
        }
        
        heartImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-20)
        }
        
        packageBG.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalTo(contentView.snp.bottom).offset(-10)
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

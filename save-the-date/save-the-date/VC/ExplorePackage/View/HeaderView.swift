//
//  HeaderView.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/12/10.
//

import Foundation
import UIKit
import SnapKit

class CustomHeaderView: UIView {
    
    var packageTitleLabel = UILabel()
    var packageTagLabel = UILabel()
    var packageAuthorLabel = UILabel()
    
    var authorProfileImages = [UIImageView]()
    
    var dividerA = UIView()
    var dividerB = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews([
            packageTitleLabel,
            packageTagLabel,
            packageAuthorLabel,
            dividerA,
            dividerB
        ])
        
        setupConstraints()
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        packageTitleLabel.setChalkFont(16)
            .text = "Title :"
        packageTagLabel.setChalkFont(16)
            .text = "Tags :"
        packageAuthorLabel.setChalkFont(16)
            .text = "Author :"
        
        dividerA.backgroundColor = .lightGray
        dividerB.backgroundColor = .lightGray
    }

    func setupConstraints() {
        packageTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.leading.equalToSuperview().offset(10)
            make.height.equalTo(30)
        }
        
        dividerA.snp.makeConstraints { make in
            make.top.equalTo(packageTitleLabel.snp.bottom).offset(7.5)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(1)
        }
        
        packageAuthorLabel.snp.makeConstraints { make in
            make.top.equalTo(packageTitleLabel.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(10)
            make.height.equalTo(30)
        }
        
        dividerB.snp.makeConstraints { make in
            make.top.equalTo(packageAuthorLabel.snp.bottom).offset(7.5)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(1)
        }
        
        packageTagLabel.snp.makeConstraints { make in
            make.top.equalTo(packageAuthorLabel.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(10)
            make.height.equalTo(30)
            make.bottom.equalToSuperview().offset(-15)
        }
    }
}

// MARK: - Additional function -
extension CustomHeaderView {
    
    func createAuthorImageViews(with images: [UIImage]) {
        // Remove old images first
        authorProfileImages.forEach { $0.removeFromSuperview() }
        authorProfileImages.removeAll()

        for (index, image) in images.enumerated() {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = 20 // Adjust as needed
            imageView.clipsToBounds = true
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.setBoarderColor(.black)
                .setBoarderWidth(1.25)

            addSubview(imageView)
            authorProfileImages.append(imageView)

            // Adjust constraints for overlay effect
            let overlayOffset: CGFloat = index > 0 ? CGFloat(15 * index) : 0

            imageView.snp.makeConstraints { make in
                make.centerY.equalTo(packageAuthorLabel.snp.centerY)
                make.leading.equalTo(packageAuthorLabel.snp.trailing).offset(10 + overlayOffset)
                make.width.height.equalTo(40)
            }

            // Ensure the last imageView is not clipped
            if index == images.count - 1 {
                imageView.snp.makeConstraints { make in
                    make.trailing.lessThanOrEqualToSuperview().offset(-10)
                }
            }
        }
    }
}

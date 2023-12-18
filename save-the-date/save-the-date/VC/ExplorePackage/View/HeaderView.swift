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
    
    // Custom tags view
    var scrollView = UIScrollView()
    var tagsStackView = UIStackView()
    
    // Label
    var packageTitleLabel = UILabel()
    var packageTagLabel = UILabel()
    var packageAuthorLabel = UILabel()
    
    // Content
    var packageTitle = UILabel()
    var authorProfileImages = [UIImageView]()
    
    var dividerA = UIView()
    var dividerB = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews([
            packageTitleLabel,
            packageTagLabel,
            packageAuthorLabel,
            packageTitle,
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
        // Content
        packageTitle.setChalkFont(24)
            .setTextColor(.black)
            .text = ""
        
        // Label
        packageTitleLabel.setChalkFont(18)
            .setTextColor(.black)
            .text = "Title :"
        packageTagLabel.setChalkFont(18)
            .setTextColor(.black)
            .text = "Tags :"
        packageAuthorLabel.setChalkFont(18)
            .setTextColor(.black)
            .text = "Author :"
        
        dividerA.backgroundColor = .lightGray
        dividerB.backgroundColor = .lightGray
    }

    func setupConstraints() {
        
        packageTitle.snp.makeConstraints { make in
            make.centerY.equalTo(packageTitleLabel.snp.centerY)
            make.leading.equalTo(packageTitleLabel.snp.trailing).offset(10)
        }
        
        packageTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(55)
            make.leading.equalToSuperview().offset(10)
            make.height.equalTo(40)
        }
        
        dividerA.snp.makeConstraints { make in
            make.top.equalTo(packageTitleLabel.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(1)
        }
        
        packageAuthorLabel.snp.makeConstraints { make in
            make.top.equalTo(packageTitleLabel.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(10)
            make.height.equalTo(40)
        }
        
        dividerB.snp.makeConstraints { make in
            make.top.equalTo(packageAuthorLabel.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(1)
        }
        
        packageTagLabel.snp.makeConstraints { make in
            make.top.equalTo(packageAuthorLabel.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(10)
            make.height.equalTo(40)
            make.bottom.equalToSuperview().offset(-30)
        }
    }
}

// MARK: - Additional function -
extension CustomHeaderView {
    
    func setupScrollView() {
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)

        scrollView.snp.makeConstraints { make in
            make.centerY.equalTo(packageTagLabel.snp.centerY)
            make.leading.equalTo(packageTagLabel.snp.trailing).offset(10)
            make.trailing.equalToSuperview()
            make.height.equalTo(40) // Adjust as needed
        }

        tagsStackView.axis = .horizontal
        tagsStackView.spacing = 8
        tagsStackView.alignment = .center
        tagsStackView.distribution = .fillProportionally

        scrollView.addSubview(tagsStackView)
        tagsStackView.translatesAutoresizingMaskIntoConstraints = false

        tagsStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(scrollView)
        }
    }

    func createTagLabels(with tags: [String]) {
        // Clear old tags
        tagsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for tag in tags {
            let tagLabel = UILabel()
            tagLabel.text = tag
            tagLabel.backgroundColor = .lightGray
            tagLabel.layer.cornerRadius = 10
            tagLabel.clipsToBounds = true
            tagLabel.textAlignment = .center
            tagLabel.font = UIFont.systemFont(ofSize: 14) // Adjust as needed
            tagLabel.textColor = .black
            tagLabel.snp.makeConstraints { make in
                make.height.equalTo(30) // Adjust as needed
            }

            tagsStackView.addArrangedSubview(tagLabel)
        }
    }
    
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
                .tintColor = .customUltraGrey

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

//
//  ScrollView.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/21.
//

import Foundation
import UIKit
import SnapKit

class HorizontalImageScrollView: UIScrollView {

    private let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupScrollView()
        setupStackView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupScrollView()
        setupStackView()
    }
    
    private func setupScrollView() {
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
    }
    
    private func setupStackView() {
        addSubview(stackView)
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .fill
        stackView.distribution = .fillEqually

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.heightAnchor.constraint(equalTo: heightAnchor)
        ])
    }
    
    func addImages(named imageNames: [String]) {
        imageNames.forEach { name in
            let imageView = UIImageView(image: UIImage(named: name))
            imageView.contentMode = .scaleAspectFit
            stackView.addArrangedSubview(imageView)
            
            imageView.snp.makeConstraints { make in
                make.width.equalTo(70)
                make.height.equalTo(70)
            }
        }
    }
}

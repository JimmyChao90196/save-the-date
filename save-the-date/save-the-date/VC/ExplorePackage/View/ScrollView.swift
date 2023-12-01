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
    
    // On event
    var onTapped: ((Int) -> Void)?

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
    
    // Additional function
    @objc private func imageTapped(_ sender: UITapGestureRecognizer) {
        if let imageView = sender.view as? UIImageView {
            let tappedIndex = imageView.tag

            onTapped?(tappedIndex)
            print(tappedIndex)
        }
    }

    func addImages(named imageNames: [String]) {
        for (index, name) in imageNames.enumerated() {
            let imageView = UIImageView(image: UIImage(named: name))
            imageView.contentMode = .scaleAspectFit
            imageView.isUserInteractionEnabled = true
            imageView.tag = index  // Set the tag to the index of the image

            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
            imageView.addGestureRecognizer(tapGestureRecognizer)

            stackView.addArrangedSubview(imageView)

            imageView.snp.makeConstraints { make in
                make.width.equalTo(100)
                make.height.equalTo(100)
            }
        }
    }
}

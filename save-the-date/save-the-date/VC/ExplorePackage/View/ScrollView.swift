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
        stackView.backgroundColor = .lightGray
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
            let imageLabelView = ImageLabelView()
            imageLabelView.imageView.image = UIImage(named: name)
            imageLabelView.imageView.isUserInteractionEnabled = true
            imageLabelView.imageView.tag = index

            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
            imageLabelView.imageView.addGestureRecognizer(tapGestureRecognizer)
            imageLabelView.label.text = "\(index + 1)"
            imageLabelView.label.setFont(UIFont(name: "HelveticaNeue-Bold", size: 40) ?? UIFont.systemFont(ofSize: 30))
            imageLabelView.setCornerRadius(20)
                .setBoarderColor(.hexToUIColor(hex: "#3F3A3A"))
                .setBoarderWidth(4)
                .clipsToBounds = true
            
            stackView.addArrangedSubview(imageLabelView)

            imageLabelView.snp.makeConstraints { make in
                make.width.equalTo(100)
                make.height.equalTo(100)
            }
        }
    }

}

// ImageWithLabel View
class ImageLabelView: UIView {
    
    let imageView = UIImageView()
    let label = UILabel()
    let darkOverlayView = UIView() // Dark overlay

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        addSubview(imageView)
        addSubview(darkOverlayView) // Add the overlay view
        addSubview(label)

        imageView.contentMode = .scaleAspectFit
        label.textAlignment = .center
        label.textColor = .white // Set label color

        // Setup the dark overlay view
        darkOverlayView.backgroundColor = UIColor.black.withAlphaComponent(0.2) // Adjust alpha for darkness
        darkOverlayView.isUserInteractionEnabled = false // Allow interaction to pass through to image

        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        darkOverlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

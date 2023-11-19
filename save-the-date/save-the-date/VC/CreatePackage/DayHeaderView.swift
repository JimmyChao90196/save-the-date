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
    let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstranit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        addSubview(titleLabel)
        titleLabel.textAlignment = .center
    }
    
    private func setupConstranit() {
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }
    }

    func setDay(_ day: Int) {
        titleLabel.text = "Day \(day)"
    }
}

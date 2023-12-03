//
//  SelectionView.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/20.
//

import Foundation
import SwiftUI
import UIKit

@objc protocol SelectionViewDataSource: AnyObject {
    
    @objc optional func numberOfButtons(selectionView: SelectionView) -> Int
    
    func buttonPerSelection(selectionView: SelectionView, index: Int) -> SelectionButton
    
    @objc optional func colorOfBar(selectionView: SelectionView) -> UIColor?
}

@objc protocol SelectionViewProtocol: AnyObject {
    
    @objc optional func didSelectButtonAt(selectionView: SelectionView, displayColor: UIColor, selectionIndex: Int)
    
    @objc optional func shouldSelect(selectionView: SelectionView, selectedIndex: Int) -> Bool
}

class SelectionView: UIView {
    // Overall containter that contains barView and buttonView
    private var overallContainer: UIView = UIView()
    private var buttonStack: UIStackView = UIStackView()
    
    private var buttons: [UIButton] = [ ]
    
    private var barView: UIView = UIView()
    private var barViewLeadingConstraint: NSLayoutConstraint = NSLayoutConstraint()
    
    weak var delegate: SelectionViewProtocol?
    weak var dataSource: SelectionViewDataSource? {
        didSet {
            setup()
        }
    }
    
    private var selectedButtonIndex: Int = 0
    private var textTintColor: UIColor = UIColor()
    private var buttonFont: UIFont = UIFont()
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // Initial setup
    func setup() {
        addSubview(overallContainer)
        initializeVerticalContainer()
        initializeButtons()
        initializeButtonUI()
        initializeHorizontalButtonStackView()
        initializeBarView()
    }
    
    // This vertical container serve as a vessel, for the barView and buttonView
    private func initializeVerticalContainer() {
        overallContainer.translatesAutoresizingMaskIntoConstraints = false
        overallContainer.addSubview(buttonStack)
        overallContainer.addSubview(barView)
        
        NSLayoutConstraint.activate([
            overallContainer.topAnchor.constraint(equalTo: topAnchor),
            overallContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            overallContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            overallContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // Creates the buttons from the buttonTitles array
    private func initializeButtons() {

        guard let dataSource else { return }
        let numberOfButton = dataSource.numberOfButtons?(selectionView: self) ?? 2
        
        for index in 0..<numberOfButton {
            let buttonModel = dataSource.buttonPerSelection(selectionView: self, index: index)
            let button: UIButton = UIButton(type: .system)
            button.setTitle(buttonModel.title, for: .normal)
            button.tintColor = buttonModel.unselectedColor
            button.titleLabel?.font = buttonModel.font
            button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
            buttons.append(button)
        }
    }
    
    // Add the buttons in a horizontal container
    private func initializeHorizontalButtonStackView() {
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttons.forEach {
            buttonStack.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            buttonStack.leadingAnchor.constraint(equalTo: overallContainer.leadingAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: overallContainer.trailingAnchor),
            buttonStack.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0)
        ])
    }
    
    // Initial bar view
    private func initializeBarView() {
        
        guard let dataSource else { return }
        
        let firstButton = buttons[0]
        barView.translatesAutoresizingMaskIntoConstraints = false
        barView.backgroundColor = dataSource.colorOfBar?(selectionView: self) ?? .blue
        barViewLeadingConstraint = barView.leadingAnchor.constraint(equalTo: firstButton.leadingAnchor)
        
        NSLayoutConstraint.activate([
            barView.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 5),
            barView.widthAnchor.constraint(equalTo: firstButton.widthAnchor),
            barView.heightAnchor.constraint(equalToConstant: 1),
            barViewLeadingConstraint
        ])
    }
    
    @objc private func buttonTapped(sender: UIButton) {
        
        // Fetch buttonIndex and feed it into the delegate arguement for later use.
        guard let buttonIndex = buttons.firstIndex(of: sender) else { return }
        guard let buttonModule = dataSource?.buttonPerSelection(
            selectionView: self,
            index: buttonIndex) else { return }
        selectedButtonIndex = buttonIndex
        
        if let isLocked = delegate?.shouldSelect?(selectionView: self, selectedIndex: buttonIndex) {
            
            if isLocked == false {
                delegate?.didSelectButtonAt?(
                    selectionView: self,
                    displayColor: buttonModule.displayColor,
                    selectionIndex: buttonIndex)
                animateBarView()
                initializeButtonUI()
            }
            
        } else {
            
            delegate?.didSelectButtonAt?(
                selectionView: self,
                displayColor: buttonModule.displayColor,
                selectionIndex: buttonIndex)
            animateBarView()
            initializeButtonUI()
        }
    }
    
    // Change text color when the button is tapped
    private func initializeButtonUI() {
        let selectedButton = buttons[selectedButtonIndex]
        guard let dataSource else { return }
        
        buttons.enumerated().forEach { index, button in
            let buttonPerSelection = dataSource.buttonPerSelection(selectionView: self, index: index)
            
            if button == selectedButton {
                button.setTitleColor(buttonPerSelection.unselectedColor, for: .normal)
            } else {
                button.setTitleColor(buttonPerSelection.selectedColor, for: .normal)
            }
        }
    }
    
    // Update constraint when the button is tapped.
    // Add animation to the this action.
    private func animateBarView() {
        let selectedButton = buttons[selectedButtonIndex]
        barViewLeadingConstraint.isActive = false
        barViewLeadingConstraint = barView.leadingAnchor.constraint(equalTo: selectedButton.leadingAnchor)
        barViewLeadingConstraint.isActive = true
        
        // This animation will animated not only constraint, but all the UI-related update.
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
}

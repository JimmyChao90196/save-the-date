//
//  DeclaritiveExtension.swift
//  save-the-date
//
//  Created by JimmyChao on 2023/11/15.
//

import Foundation
import UIKit

// MARK: - Add multiple subview
extension UIView {
    
    @discardableResult
    func addSubviews(_ views: [UIView]) -> Self {
        views.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        return self
    }
}

// MARK: - UIButton -
extension UIButton {
    
    @discardableResult
    func customSetup( _ text: String,
                      _ fontName: String,
                      _ fontSize: CGFloat,
                      _ spacing: CGFloat,
                      hexColor: String) -> Self {
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: fontName, size: fontSize) ?? UIFont(),
            .kern: spacing * fontSize,
            .foregroundColor: UIColor.hexStringToUIColor(hex: hexColor)
        ]
        
        let attribText = NSAttributedString(string: text, attributes: attributes)
        self.setAttributedTitle(attribText, for: .normal)
        
        return self
    }
    
    @discardableResult
    func setTarget(_ target: Any?, action: Selector, for events: UIControl.Event) -> Self {
        addTarget(target, action: action, for: events)
        return self
    }
}

// MARK: - Setup UIEelements -
extension UIView {
    @discardableResult
    func setbackgroundColor(_ color: UIColor) -> Self {
        self.backgroundColor = color
        return self
    }
    
    @discardableResult
    func setCornerRadius(_ radius: CGFloat) -> Self {
        self.layer.cornerRadius = radius
        return self
    }
    
    @discardableResult
    func setBoarderWidth(_ width: CGFloat) -> Self {
        self.layer.borderWidth = width
        return self
    }
    
    @discardableResult
    func setBoarderColor(_ color: UIColor) -> Self {
        self.layer.borderColor = color.cgColor
        return self
    }
    
    @discardableResult
    func setAlpha(_ alpha: CGFloat) -> Self {
        self.alpha = alpha
        return self
    }
    
    @discardableResult
    func offAutoResize() -> Self {
        self.translatesAutoresizingMaskIntoConstraints = false
        return self
    }
}

// MARK: - UILabel -
extension UILabel {
    
    @discardableResult
    func setFont(_ font: UIFont) -> Self {
        self.font = font
        return self
    }
    
    @discardableResult
    func setChalkFont(_ size: CGFloat) -> Self {
        self.font = UIFont(name: "ChalkboardSE-Regular", size: size)
        return self
    }
    
    @discardableResult
    func setTextColor(_ color: UIColor) -> Self {
        self.textColor = color
        return self
    }
    
    @discardableResult
    func customSetup( _ text: String,
                      _ fontName: String,
                      _ fontSize: CGFloat,
                      _ spacing: CGFloat,
                      hexColor: String) -> Self {
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: fontName, size: fontSize) ?? UIFont(),
            .kern: spacing * fontSize,
            .foregroundColor: UIColor.hexStringToUIColor(hex: hexColor)
        ]
        
        let attribText = NSAttributedString(string: text, attributes: attributes)
        self.attributedText = attribText
        
        return self
    }
}

// MARK: - UIColor -
extension UIColor {
    
    // The purpose of this function is to convert hex color to rgb.
    static func hexToUIColor(hex: String) -> UIColor {
        var inputString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if inputString.hasPrefix("#") {
            inputString.remove(at: inputString.startIndex)
        }
        
        if (inputString.count) != 6 {
            return UIColor.gray
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: inputString).scanHexInt64(&rgbValue)
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

// MARK: - Short constraint syntax -
extension UIView {
    
    @discardableResult
    func trailingConstr(to anchor: NSLayoutXAxisAnchor, _ distance: CGFloat) -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        trailingAnchor.constraint(equalTo: anchor, constant: distance).isActive = true
        return self
    }
    
    @discardableResult
    func leadingConstr(to anchor: NSLayoutXAxisAnchor, _ distance: CGFloat) -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        leadingAnchor.constraint(equalTo: anchor, constant: distance).isActive = true
        return self
    }
    
    @discardableResult
    func topConstr(to anchor: NSLayoutYAxisAnchor, _ distance: CGFloat) -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: anchor, constant: distance).isActive = true
        return self
    }
    
    @discardableResult
    func bottomConstr(to anchor: NSLayoutYAxisAnchor, _ distance: CGFloat) -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        bottomAnchor.constraint(equalTo: anchor, constant: distance).isActive = true
        return self
    }
    
    @discardableResult
    func widthConstr(_ width: CGFloat) -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: width).isActive = true
        return self
    }
    
    @discardableResult
    func heightConstr(_ height: CGFloat) -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
        return self
    }
    
    @discardableResult
    func centerXConstr(to anchor: NSLayoutXAxisAnchor, _ distance: CGFloat = 0) -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: anchor, constant: distance).isActive = true
        return self
    }
    
    @discardableResult
    func centerYConstr(to anchor: NSLayoutYAxisAnchor, _ distance: CGFloat = 0) -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: anchor, constant: distance).isActive = true
        return self
    }
}

// MARK: - UIViewController -
extension UIViewController {
    
    func presentSimpleAlert(title: String, message: String, buttonText: String, buttonAction: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: buttonText, style: .default) { _ in
            buttonAction?()
        }
        
        alert.addAction(action)
        
        // If you want to add a cancel action as well
        // let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        // alert.addAction(cancelAction)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func presentAlertWithTextField(
        title: String,
        message: String,
        buttonText: String,
        cancelButtonText: String = "Cancel",
        textFieldConfiguration: ((UITextField) -> Void)? = nil,
        completion: @escaping (String?) -> Void) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

            // Configure text field
            alert.addTextField { textField in
                textField.setBoarderColor(.hexToUIColor(hex: "#CCCCCC"))
                    .setBoarderWidth(1)
                textFieldConfiguration?(textField)
            }

            // Action for the button
            let action = UIAlertAction(title: buttonText, style: .default) { _ in
                let textField = alert.textFields?.first
                completion(textField?.text)
            }
            alert.addAction(action)

            // Cancel action
            let cancelAction = UIAlertAction(title: cancelButtonText, style: .cancel) { _ in
                completion(nil)
            }
            alert.addAction(cancelAction)

            // Present the alert
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
}

// MARK: - Formatted extension -

extension String {
    func customFormat() -> String? {
        // DateFormatter to parse the ISO 8601 date string
        let iso8601Formatter = ISO8601DateFormatter()
        iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        // Parse the string into a Date object
        guard let date = iso8601Formatter.date(from: self) else { return nil }

        // DateFormatter to format the Date object into the desired string format
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Taipei") // Set timezone to Asia/Taipei
        dateFormatter.dateFormat = "EEEE HH:mm:ss" // Weekday, hour, minute, second

        // Format the Date object into a string
        return dateFormatter.string(from: date)
    }
}

extension TimeInterval {
    func customFormat() -> String {
        // Create a Date object from the TimeInterval (which is seconds since reference date)
        let date = Date(timeIntervalSinceReferenceDate: self)

        // DateFormatter to format the Date object into the desired string format
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Taipei") // Set timezone to Asia/Taipei
        dateFormatter.dateFormat = "EEEE HH:mm:ss" // Weekday, hour, minute, second

        // Format the Date object into a string
        return dateFormatter.string(from: date)
    }
}

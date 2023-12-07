//
//  CustomShape.swift
//  STYLiSH
//
//  Created by JimmyChao on 2023/11/4.
//  Copyright © 2023 AppWorks School. All rights reserved.
//

import Foundation
import UIKit

class CustomShapeView: UIView {
    
    var filledCol = UIColor.systemPink
    
    convenience init(color: UIColor, frame: CGRect) {
        self.init(frame: frame)
        self.filledCol = color
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Start with a rectangle that's the full size of the view
        let rectanglePath = UIBezierPath(rect: rect)
        
        // Create circle paths that will "cut out" the bottom corners of the rectangle
        let leftCirclePath = UIBezierPath(ovalIn: CGRect(x: rect.minX - rect.height,
                                                         y: rect.maxY - rect.height,
                                                         width: rect.height * 2,
                                                         height: rect.height * 2))
        let rightCirclePath = UIBezierPath(ovalIn: CGRect(x: rect.maxX - rect.height,
                                                          y: rect.maxY - rect.height,
                                                          width: rect.height * 2,
                                                          height: rect.height * 2))
        
        // Cut the corners out of the rectangle by using the even-odd fill rule
        rectanglePath.append(leftCirclePath)
        rectanglePath.append(rightCirclePath)
        rectanglePath.usesEvenOddFillRule = true
        
        // Set the fill color
        self.filledCol.setFill()
        
        // Fill the path
        rectanglePath.fill()
        
        // Clip the context to the combined path
        context.saveGState()
        rectanglePath.addClip()
        context.restoreGState()
    }
}

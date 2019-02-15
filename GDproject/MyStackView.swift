//
//  MyStackView.swift
//  GDproject
//
//  Created by cstore on 14/02/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import UIKit

class MyStackView: UIStackView {

    var isFull: Bool = true

    
    override var bounds: CGRect {
        didSet{
            if frame.height == 300 && !isFull {
                let gradientLayer = CAGradientLayer()
                gradientLayer.colors = [UIColor(displayP3Red: 255, green: 255, blue: 255, alpha: 0).cgColor, UIColor.white.cgColor]
                gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
                gradientLayer.frame = self.bounds
                self.layer.addSublayer(gradientLayer)
            }
        }
    }
}

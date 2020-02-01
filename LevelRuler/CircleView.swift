//
//  CircleView.swift
//  LevelRuler
//
//  Created by Neo Yi Siang on 30/1/2020.
//  Copyright © 2020 Neo Yi Siang. All rights reserved.
//

import UIKit

class CircleView: UIView {

    var circleColor: UIColor!
    var middleCircleColor: UIColor!
    var circleSize: CGFloat!
    
    init(size: CGFloat, color: UIColor, completeColor: UIColor) {
        super.init(frame: CGRect(x: 0, y: 0, width: size, height: size))
        circleSize = size
        circleColor = color
        middleCircleColor = completeColor
        translatesAutoresizingMaskIntoConstraints = false
        
        self.layer.cornerRadius = circleSize / 2
        self.layer.borderColor = UIColor.clear.cgColor
        self.clipsToBounds = true
        self.backgroundColor = circleColor
        
        frame.origin.x = UIScreen.main.bounds.width / 2 - circleSize / 2
        frame.origin.y = UIScreen.main.bounds.height / 2 - circleSize / 2
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func move(to point: CGPoint, inMiddle: Bool = false) {
        UIView.animate(withDuration: 0.1) {
            self.frame.origin.x = point.x - self.circleSize / 2
            self.frame.origin.y = point.y - self.circleSize / 2
        }
        if inMiddle && backgroundColor != middleCircleColor{
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                self.backgroundColor = self.middleCircleColor
            }, completion: nil)
        }
        else if !inMiddle && backgroundColor != circleColor {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                self.backgroundColor = self.circleColor
            }, completion: nil)
        }
    }
    
}


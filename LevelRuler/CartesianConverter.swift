//
//  CartesianConverter.swift
//  LevelRuler
//
//  Created by Neo Yi Siang on 30/1/2020.
//  Copyright © 2020 Neo Yi Siang. All rights reserved.
//

import UIKit

class CartesianConverter {
    
    let width: CGFloat
    let halfWidth: CGFloat
    let height: CGFloat
    let halfHeight: CGFloat
    
    init (width: CGFloat, height: CGFloat) {
        self.width = width
        self.height = height
        self.halfWidth = width / 2
        self.halfHeight = height / 2
    }
    
    func convertMiddleToTopLeft (_ point: CGPoint) -> CGPoint {
        let x = point.x + halfWidth
        let y = -point.y + halfHeight
        
        return CGPoint(x: x, y: y)
    }
    
}

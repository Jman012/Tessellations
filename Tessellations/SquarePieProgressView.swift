//
//  SquarePieProgressView.swift
//  Tessellations
//
//  Created by James Linnell on 9/1/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit

class SquarePieProgressView: UIView {
    
    var percent: CGFloat = 0.0 {
        didSet { self.setNeedsDisplay() }
    }
    
    var progressColor: UIColor? {
        didSet { self.setNeedsDisplay() }
    }

    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        
        let center = CGPoint(x: rect.width / 2.0, y: rect.height / 2.0)
        
        let path = CGPathCreateMutable()
        CGPathMoveToPoint   (path, nil, center.x, center.y)
        CGPathAddArc        (path, nil,
                             center.x, center.y,                                   /* Centered around */
                             rect.height, CGFloat(-90.0.degrees),                  /* With radius, starting at angle */
                             CGFloat(-90.0.degrees) + (2*CGFloat(M_PI) * percent), /* Ending at angle */
                             false)                                                /* Counterclockwise */
        CGPathCloseSubpath  (path)
        
        let ctx = UIGraphicsGetCurrentContext()
        CGContextClearRect(ctx, rect)
        CGContextAddPath(ctx, path)
        CGContextSetFillColorWithColor(ctx, self.progressColor?.CGColor)
        CGContextFillPath(ctx)
    }

}

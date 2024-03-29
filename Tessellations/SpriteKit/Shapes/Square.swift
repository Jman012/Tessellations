//
//  Square.swift
//  Tessellations
//
//  Created by James Linnell on 8/15/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit
import SpriteKit

class Square: Shape {
    
    var width: CGFloat {
        get { return self.sideLength }
    }
    var halfWidth: CGFloat {
        get { return width / 2.0 }
    }
    var diagonal: CGFloat {
        get { return CGFloat(sqrt(2.0)) * width }
    }
    
    init(width theWidth: CGFloat, pipeWidth thePipeWidth: CGFloat) {
        super.init()
        
        self.sideLength = theWidth
        self.pipeWidth  = thePipeWidth
        self.pipeLength = self.halfWidth
        
        
        let squarePath = CGPathCreateMutable()
        CGPathMoveToPoint   (squarePath, nil, -halfWidth, -halfWidth)
        CGPathAddLineToPoint(squarePath, nil,  halfWidth, -halfWidth)
        CGPathAddLineToPoint(squarePath, nil,  halfWidth,  halfWidth)
        CGPathAddLineToPoint(squarePath, nil, -halfWidth,  halfWidth)
        CGPathCloseSubpath(squarePath)
        var transformScale = CGAffineTransformMakeScale((width - margin) / width, (width - margin) / width)
        self.path = CGPathCreateCopyByTransformingPath(squarePath, &transformScale)
        
        let squarePipePath = CGPathCreateMutable()
        CGPathMoveToPoint   (squarePipePath, nil, pipeWidth * (-1/2), halfWidth - 0.5)
        CGPathAddLineToPoint(squarePipePath, nil, pipeWidth * (1/2),  halfWidth - 0.5)
        CGPathAddLineToPoint(squarePipePath, nil, pipeWidth * (1/2),  0)
        CGPathAddArc        (squarePipePath, nil, 0, 0, pipeWidth * (1/2), 0, CGFloat(M_PI), true)
        CGPathCloseSubpath  (squarePipePath)
        transformScale = CGAffineTransformMakeScale(1.0, (width - margin) / width)
        self.pipePath = CGPathCreateCopyByTransformingPath(squarePipePath, &transformScale)
        
    }
    
    convenience init(diagonal: CGFloat, pipeWidth: CGFloat) {
        self.init(width: diagonal / CGFloat(sqrt(2.0)), pipeWidth: pipeWidth)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    

}

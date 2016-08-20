//
//  Triangle.swift
//  Tessellations
//
//  Created by James Linnell on 8/16/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit
import SpriteKit

class TriangleUp: Shape {
    
    // Measurements: http://www.treenshop.com/Treenshop/ArticlesPages/FiguresOfInterest_Article/The%20Equilateral%20Triangle_files/image036.gif
    // http://www.treenshop.com/Treenshop/ArticlesPages/FiguresOfInterest_Article/The%20Equilateral%20Triangle.htm

    var R: CGFloat {
        get { return sideLength * CGFloat(sqrt(3.0)) / 3.0 }
    }
    var r: CGFloat {
        get { return sideLength * CGFloat(sqrt(3.0)) / 6.0 }
    }
    var height: CGFloat {
        get { return R + r }
    }
    
    init(sideLength: CGFloat, pipeWidth: CGFloat) {
        super.init()
        
        self.sideLength = sideLength
        self.pipeWidth = pipeWidth
        self.pipeLength = r
        
        
        let triangleUpPath = CGPathCreateMutable()
        var angle = 90.0
        CGPathMoveToPoint(triangleUpPath, nil, R * CGFloat(cos(angle.degrees)), R * CGFloat(sin(angle.degrees)))
        for _ in 0..<2 {
            angle += 120.0
            CGPathAddLineToPoint(triangleUpPath, nil, R * CGFloat(cos(angle.degrees)), R * CGFloat(sin(angle.degrees)))
        }
        CGPathCloseSubpath(triangleUpPath)
        self.path = triangleUpPath
        
        
        let trianglePipePath = CGPathCreateMutable()
        CGPathMoveToPoint   (trianglePipePath, nil, pipeWidth * (-1/2), pipeLength - 0.5)
        CGPathAddLineToPoint(trianglePipePath, nil, pipeWidth * (1/2), pipeLength - 0.5)
        CGPathAddLineToPoint(trianglePipePath, nil, pipeWidth * (1/2), 0)
        CGPathAddArc        (trianglePipePath, nil, 0, 0, pipeWidth * (1/2), 0, CGFloat(M_PI), true)
        CGPathCloseSubpath  (trianglePipePath)
        self.pipePath = trianglePipePath
    }
    
    convenience init(height: CGFloat, pipeWidth: CGFloat) {
        self.init(sideLength: height * 2.0 / CGFloat(sqrt(3.0)), pipeWidth: pipeWidth)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

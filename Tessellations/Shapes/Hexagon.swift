//
//  Hexagon.swift
//  Tessellations
//
//  Created by James Linnell on 8/16/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit
import SpriteKit

class Hexagon: Shape {

    var edgeRadius: CGFloat {
        get { return cornerRadius * CGFloat(sqrt(3.0)) / 2.0 }
    }
    var cornerRadius: CGFloat {
        get { return sideLength }
    }
    var edgeDiameter: CGFloat {
        get { return edgeRadius * 2 }
    }
    var cornerDiameter: CGFloat {
        get { return cornerRadius * 2 }
    }
    var triangleHeight: CGFloat {
        get { return edgeRadius }
    }
    var triangleSide: CGFloat {
        get { return cornerRadius }
    }
    
    init(edgeRadius theEdgeRadius: CGFloat, pipeWidth thePipeWidth: CGFloat) {
        
        super.init()
        
        self.sideLength = theEdgeRadius * 2.0 / CGFloat(sqrt(3.0))
        self.pipeWidth = thePipeWidth
        self.pipeLength = edgeRadius
        
        var hexPath = CGPathCreateMutable()
        var angle = 0.0
        CGPathMoveToPoint(hexPath, nil, edgeRadius * CGFloat(cos(angle.degrees)), edgeRadius * CGFloat(sin(angle.degrees)))
        for _ in 0..<5 {
            angle += 60.0
            CGPathAddLineToPoint(hexPath, nil, edgeRadius * CGFloat(cos(angle.degrees)), edgeRadius * CGFloat(sin(angle.degrees)))
        }
        CGPathCloseSubpath(hexPath)
        var transformScale = CGAffineTransformMakeScale(0.95, 0.95)
        hexPath = CGPathCreateMutableCopyByTransformingPath(hexPath, &transformScale)!
        self.path = hexPath
        
        
        var hexPipePath = CGPathCreateMutable()
        CGPathMoveToPoint   (hexPipePath, nil, self.pipeWidth * (-1/2), self.pipeLength - 0.5)
        CGPathAddLineToPoint(hexPipePath, nil, self.pipeWidth * (1/2), self.pipeLength - 0.5)
        CGPathAddLineToPoint(hexPipePath, nil, self.pipeWidth * (1/2), 0)
        CGPathAddArc        (hexPipePath, nil, 0, 0, self.pipeWidth * (1/2), 0, CGFloat(M_PI), true)
        CGPathCloseSubpath  (hexPipePath)
        transformScale = CGAffineTransformMakeScale(1.0, 0.95)
        hexPipePath = CGPathCreateMutableCopyByTransformingPath(hexPipePath, &transformScale)!
        self.pipePath = hexPipePath
    }
    
    convenience init(cornerRadius: CGFloat, pipeWidth: CGFloat) {
        self.init(edgeRadius: cornerRadius * CGFloat(sqrt(3.0)) / 2.0, pipeWidth: pipeWidth)
    }
    
    convenience init(edgeDiameter: CGFloat, pipeWidth: CGFloat) {
        self.init(edgeRadius: edgeDiameter / 2.0, pipeWidth:  pipeWidth)
    }
    
    convenience init(cornerDiameter: CGFloat, pipeWidth: CGFloat) {
        self.init(cornerRadius: cornerDiameter / 2.0, pipeWidth: pipeWidth)
    }
    
    convenience init(triangleHeight: CGFloat, pipeWidth: CGFloat) {
        self.init(edgeRadius: triangleHeight, pipeWidth: pipeWidth)
    }
    
    convenience init(triangleSide: CGFloat, pipeWidth: CGFloat) {
        self.init(cornerRadius: triangleSide, pipeWidth: pipeWidth)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

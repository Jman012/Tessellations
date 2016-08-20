//
//  Dodecagon.swift
//  Tessellations
//
//  Created by James Linnell on 8/16/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit
import SpriteKit

class Dodecagon: Shape {

    var edgeRadius: CGFloat {
        get { return sideLength * 0.5 * (2 + CGFloat(sqrt(3.0))) }
    }
    var cornerRadius: CGFloat {
        get { return sideLength * 0.5 * CGFloat(sqrt(6.0) + sqrt(2.0)) }
    }
    var edgeDiameter: CGFloat {
        get { return edgeRadius * 2 }
    }
    var cornerDiameter: CGFloat {
        get { return cornerRadius * 2 }
    }
    
    init(sideLength: CGFloat, pipeWidth: CGFloat) {
        
        super.init()
        
        self.sideLength = sideLength
        self.pipeWidth = pipeWidth
        self.pipeLength = edgeRadius
        
        let hexPath = CGPathCreateMutable()
        var angle = 30.0 / 2.0
        CGPathMoveToPoint(hexPath, nil, cornerRadius * CGFloat(cos(angle.degrees)), cornerRadius * CGFloat(sin(angle.degrees)))
        for _ in 0..<11 {
            angle += 30.0
            CGPathAddLineToPoint(hexPath, nil, cornerRadius * CGFloat(cos(angle.degrees)), cornerRadius * CGFloat(sin(angle.degrees)))
        }
        CGPathCloseSubpath(hexPath)
        self.path = hexPath
        
        
        let hexPipePath = CGPathCreateMutable()
        CGPathMoveToPoint   (hexPipePath, nil, self.pipeWidth * (-1/2), self.pipeLength - 0.5)
        CGPathAddLineToPoint(hexPipePath, nil, self.pipeWidth * (1/2), self.pipeLength - 0.5)
        CGPathAddLineToPoint(hexPipePath, nil, self.pipeWidth * (1/2), 0)
        CGPathAddArc        (hexPipePath, nil, 0, 0, self.pipeWidth * (1/2), 0, CGFloat(M_PI), true)
        CGPathCloseSubpath  (hexPipePath)
        self.pipePath = hexPipePath
    }
    
    convenience init(edgeRadius: CGFloat, pipeWidth: CGFloat) {
        self.init(sideLength: edgeRadius * 2.0 * CGFloat(2.0 - sqrt(3.0)), pipeWidth: pipeWidth)
    }
    
    convenience init(cornerRadius: CGFloat, pipeWidth: CGFloat) {
        self.init(sideLength: cornerRadius * 2.0 * 0.25 * CGFloat(sqrt(6.0) - sqrt(2.0)), pipeWidth: pipeWidth)
    }
    
    convenience init(edgeDiameter: CGFloat, pipeWidth: CGFloat) {
        self.init(edgeRadius: edgeDiameter / 2.0, pipeWidth:  pipeWidth)
    }
    
    convenience init(cornerDiameter: CGFloat, pipeWidth: CGFloat) {
        self.init(cornerRadius: cornerDiameter / 2.0, pipeWidth: pipeWidth)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

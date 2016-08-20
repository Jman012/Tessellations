//
//  Octagon.swift
//  Tessellations
//
//  Created by James Linnell on 8/16/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit
import SpriteKit

class Octagon: Shape {
    
    /* Calculations source: http://www.had2know.com/academics/octagon-measurement-calculator.html */

    var edgeRadius: CGFloat {
        get { return edgeDiameter * 0.5 }
    }
    var cornerRadius: CGFloat {
        get { return cornerDiameter * 0.5 }
    }
    var edgeDiameter: CGFloat {
        get { return self.sideLength * (1 + CGFloat(sqrt(2.0))) }
    }
    var cornerDiameter: CGFloat {
        get { return self.sideLength * CGFloat(sqrt(4 + 2*sqrt(2.0))) }
    }
    
    init(sideLength theSideLength: CGFloat, pipeWidth thePipeWidth: CGFloat) {
        
        super.init()
        
        self.sideLength = theSideLength
        self.pipeWidth = thePipeWidth
        self.pipeLength = edgeRadius
        
        let octPath = CGPathCreateMutable()
        var angle = 45.0 / 2
        CGPathMoveToPoint(octPath, nil, cornerRadius * CGFloat(cos(angle.degrees)), cornerRadius * CGFloat(sin(angle.degrees)))
        for _ in 0..<7 {
            angle += 45.0
            CGPathAddLineToPoint(octPath, nil, cornerRadius * CGFloat(cos(angle.degrees)), cornerRadius * CGFloat(sin(angle.degrees)))
        }
        CGPathCloseSubpath(octPath)
        self.path = octPath
        
        
        let octPipePath = CGPathCreateMutable()
        CGPathMoveToPoint   (octPipePath, nil, self.pipeWidth * (-1/2), self.pipeLength - 0.5)
        CGPathAddLineToPoint(octPipePath, nil, self.pipeWidth * (1/2), self.pipeLength - 0.5)
        CGPathAddLineToPoint(octPipePath, nil, self.pipeWidth * (1/2), 0)
        CGPathAddArc        (octPipePath, nil, 0, 0, self.pipeWidth * (1/2), 0, CGFloat(M_PI), true)
        CGPathCloseSubpath  (octPipePath)
        self.pipePath = octPipePath
    }
    
    convenience init(edgeRadius: CGFloat, pipeWidth: CGFloat) {
        self.init(edgeDiameter: edgeRadius * 2.0, pipeWidth: pipeWidth)
    }
    
    convenience init(cornerRadius: CGFloat, pipeWidth: CGFloat) {
        self.init(cornerDiameter: cornerRadius * 2.0, pipeWidth: pipeWidth)
    }
    
    convenience init(edgeDiameter: CGFloat, pipeWidth: CGFloat) {
        self.init(sideLength: edgeDiameter / (1 + CGFloat(sqrt(2.0))), pipeWidth: pipeWidth)
    }
    
    convenience init(cornerDiameter: CGFloat, pipeWidth: CGFloat) {
        self.init(sideLength: cornerDiameter / CGFloat(sqrt(4.0 + 2.0 * sqrt(2.0))), pipeWidth: pipeWidth)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

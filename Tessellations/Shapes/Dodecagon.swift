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
        
        let dodecaPath = CGPathCreateMutable()
        var angle = 30.0 / 2.0
        CGPathMoveToPoint(dodecaPath, nil, cornerRadius * CGFloat(cos(angle.degrees)), cornerRadius * CGFloat(sin(angle.degrees)))
        for _ in 0..<11 {
            angle += 30.0
            CGPathAddLineToPoint(dodecaPath, nil, cornerRadius * CGFloat(cos(angle.degrees)), cornerRadius * CGFloat(sin(angle.degrees)))
        }
        CGPathCloseSubpath(dodecaPath)
        var transformScale = CGAffineTransformMakeScale((edgeDiameter - margin) / edgeDiameter, (edgeDiameter - margin) / edgeDiameter)
        self.path = CGPathCreateCopyByTransformingPath(dodecaPath, &transformScale)
        
        
        let dodecaPipePath = CGPathCreateMutable()
        CGPathMoveToPoint   (dodecaPipePath, nil, self.pipeWidth * (-1/2), self.pipeLength - 0.5)
        CGPathAddLineToPoint(dodecaPipePath, nil, self.pipeWidth * (1/2), self.pipeLength - 0.5)
        CGPathAddLineToPoint(dodecaPipePath, nil, self.pipeWidth * (1/2), 0)
        CGPathAddArc        (dodecaPipePath, nil, 0, 0, self.pipeWidth * (1/2), 0, CGFloat(M_PI), true)
        CGPathCloseSubpath  (dodecaPipePath)
        transformScale = CGAffineTransformMakeScale(1.0, (edgeDiameter - margin/2.0) / edgeDiameter)
        self.pipePath = CGPathCreateCopyByTransformingPath(dodecaPipePath, &transformScale)
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

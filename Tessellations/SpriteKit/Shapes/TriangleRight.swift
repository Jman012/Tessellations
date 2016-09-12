//
//  TriangleRight.swift
//  Tessellations
//
//  Created by James Linnell on 8/16/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit
import SpriteKit

class TriangleRight: TriangleUp {
    
    override init(sideLength: CGFloat, pipeWidth: CGFloat) {
        super.init(sideLength: sideLength, pipeWidth: pipeWidth)
        
        var transformRotate = CGAffineTransformMakeRotation(CGFloat(270.0.degrees))
        let triangleDownPath = CGPathCreateMutableCopyByTransformingPath(self.path, &transformRotate)!
        self.path = triangleDownPath
    }
    
    convenience init(height: CGFloat, pipeWidth: CGFloat) {
        self.init(sideLength: height * 2.0 / CGFloat(sqrt(3.0)), pipeWidth: pipeWidth)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

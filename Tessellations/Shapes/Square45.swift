//
//  Square45.swift
//  Tessellations
//
//  Created by James Linnell on 8/15/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit
import SpriteKit

class Square45: Square {
    
    override init(width theWidth: CGFloat, pipeWidth thePipeWidth: CGFloat) {
        super.init(width: theWidth, pipeWidth: thePipeWidth)
        
        var transformRotate = CGAffineTransformMakeRotation(CGFloat(45.0.degrees))
        let square45Path = CGPathCreateMutableCopyByTransformingPath(self.path, &transformRotate)!
        self.path = square45Path
        
    }
    
    convenience init(diagonal: CGFloat, pipeWidth: CGFloat) {
        self.init(width: diagonal / CGFloat(sqrt(2.0)), pipeWidth: pipeWidth)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
}

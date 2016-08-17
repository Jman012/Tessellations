//
//  SquareN30.swift
//  Tessellations
//
//  Created by James Linnell on 8/17/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit
import SpriteKit

class SquareN30: Square {

    override init(width theWidth: CGFloat, pipeWidth thePipeWidth: CGFloat) {
        super.init(width: theWidth, pipeWidth: thePipeWidth)
        
        var transformRotate = CGAffineTransformMakeRotation(CGFloat(330.0.degrees))
        let squareN30Path = CGPathCreateMutableCopyByTransformingPath(self.path, &transformRotate)!
        self.path = squareN30Path
        
    }
    
    convenience init(diagonal: CGFloat, pipeWidth: CGFloat) {
        self.init(width: diagonal / CGFloat(sqrt(2.0)), pipeWidth: pipeWidth)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

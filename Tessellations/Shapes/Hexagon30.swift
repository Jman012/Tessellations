//
//  Hexagon30.swift
//  Tessellations
//
//  Created by James Linnell on 8/18/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit
import SpriteKit

class Hexagon30: Hexagon {
    
    override init(edgeRadius: CGFloat, pipeWidth: CGFloat) {
        super.init(edgeRadius: edgeRadius, pipeWidth: pipeWidth)
        
        var transformRotate = CGAffineTransformMakeRotation(CGFloat(30.0.degrees))
        let hexagon30Path = CGPathCreateMutableCopyByTransformingPath(self.path, &transformRotate)!
        self.path = hexagon30Path
        
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

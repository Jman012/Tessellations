//
//  Shape.swift
//  Tessellations
//
//  Created by James Linnell on 8/15/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit
import SpriteKit

class Shape {
    var path:       CGPath!
    var pipePath:   CGPath!
    var sideLength: CGFloat = 0
    var pipeLength: CGFloat = 0
    var pipeWidth:  CGFloat = 0
    
    let margin: CGFloat = 3.0
    
    init() {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

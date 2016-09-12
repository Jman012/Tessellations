//
//  PipeNode.swift
//  Tessellations
//
//  Created by James Linnell on 8/26/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit
import SpriteKit

class PipeNode: SKSpriteNode {

    var row: Int
    var col: Int
    var logicalDirection: Direction
    var enabled: Bool
    
    init() {
        row = -1
        col = -1
        logicalDirection = .North
        enabled = false
        super.init(texture: nil, color: UIColor.clearColor(), size: CGSizeZero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

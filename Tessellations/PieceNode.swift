//
//  PieceNode.swift
//  Tessellations
//
//  Created by James Linnell on 8/20/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit
import SpriteKit

class PieceNode: SKShapeNode {
    
    var row: Int?
    var col: Int?

    var pipeNodes: [Direction: SKShapeNode] = [:]
    var bubble: SKShapeNode?
    var rootMarker: SKShapeNode?
}

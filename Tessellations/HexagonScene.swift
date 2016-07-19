//
//  HexagonScene.swift
//  Tessellations
//
//  Created by James Linnell on 7/18/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit
import SpriteKit

class HexagonScene: AbstractGameBoardScene {
    
    var hexDiameter: CGFloat = 0
    var adjustedDiameter: CGFloat = 0
    
    override func initLogicalBoard() {
        self.logicalBoard = HexagonBoard(width: self.logicalBoardWidth, height: self.logicalBoardHeight)
    }

    override func setShapePaths() {
        
        hexDiameter =
            size.width / (ceil(CGFloat(self.logicalBoardWidth) / CGFloat(2.0)) + ((floor(CGFloat(self.logicalBoardWidth) / CGFloat(2.0))) * CGFloat(cos(60.0.degrees)))) / CGFloat(2.0)
        adjustedDiameter = hexDiameter * CGFloat(sin(60.0.degrees))
        
        var hexPath = CGPathCreateMutable()
        var angle = 0.0
        CGPathMoveToPoint(hexPath, nil, hexDiameter * CGFloat(cos(angle.degrees)), hexDiameter * CGFloat(sin(angle.degrees)))
        for _ in 0..<5 {
            angle += 60.0
            CGPathAddLineToPoint(hexPath, nil, hexDiameter * CGFloat(cos(angle.degrees)), hexDiameter * CGFloat(sin(angle.degrees)))
        }
        CGPathCloseSubpath(hexPath)
        var transformScale = CGAffineTransformMakeScale(0.95, 0.95)
        hexPath = CGPathCreateMutableCopyByTransformingPath(hexPath, &transformScale)!
        self.shapePaths[.Hexagon] = hexPath
        
    }
    
    override func pieceToPoint(piece: Piece) -> CGPoint {
        let x = hexDiameter + (CGFloat(piece.col) * (hexDiameter + hexDiameter * CGFloat(cos(60.0.degrees))))
        var y = adjustedDiameter + (CGFloat(piece.row) * adjustedDiameter * 2)
        if piece.col % 2 == 1 {
            y += adjustedDiameter
        }
        return CGPoint(x: x, y: y)
    }
}

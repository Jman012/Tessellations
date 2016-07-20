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
    var totalHeight: CGFloat = 0
    
    override func initLogicalBoard() -> AbstractGameBoard {
        return HexagonBoard(width: self.logicalBoardWidth, height: self.logicalBoardHeight)
    }

    override func setShapePaths() {
        
        hexDiameter =
            size.width / (ceil(CGFloat(self.logicalBoardWidth) / CGFloat(2.0)) + ((floor(CGFloat(self.logicalBoardWidth) / CGFloat(2.0))) * CGFloat(cos(60.0.degrees)))) / CGFloat(2.0)
        adjustedDiameter = hexDiameter * CGFloat(sin(60.0.degrees))
        totalHeight = CGFloat(self.logicalBoardHeight * 2) * adjustedDiameter
        let pipeWidth = adjustedDiameter / 2.0
        
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
        
        
        var hexPipePath = CGPathCreateMutable()
        CGPathMoveToPoint   (hexPipePath, nil, pipeWidth * (-1/2), adjustedDiameter - 0.5)
        CGPathAddLineToPoint(hexPipePath, nil, pipeWidth * (1/2), adjustedDiameter - 0.5)
        CGPathAddLineToPoint(hexPipePath, nil, pipeWidth * (1/2), 0)
        CGPathAddArc        (hexPipePath, nil, 0, 0, pipeWidth * (1/2), 0, CGFloat(M_PI), true)
        CGPathCloseSubpath  (hexPipePath)
        transformScale = CGAffineTransformMakeScale(1.0, 0.95)
        hexPipePath = CGPathCreateMutableCopyByTransformingPath(hexPipePath, &transformScale)!
        self.pipePaths[.Hexagon] = hexPipePath
        
    }
    
    override func pieceToPoint(piece: Piece) -> CGPoint {
        let x = hexDiameter + (CGFloat(piece.col) * (hexDiameter + hexDiameter * CGFloat(cos(60.0.degrees))))
        var y = 2 * adjustedDiameter + (CGFloat(piece.row) * adjustedDiameter * 2)
        if piece.col % 2 == 0 {
            y += adjustedDiameter
        }
        return CGPoint(x: x, y: size.height - y - (size.height - totalHeight)/2)
    }
}

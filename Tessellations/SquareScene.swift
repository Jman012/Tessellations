//
//  SquareScene.swift
//  Tessellations
//
//  Created by James Linnell on 7/20/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit
import SpriteKit

class SquareScene: AbstractGameBoardScene {
    
    var squareWidth: CGFloat = 0
    var totalHeight: CGFloat = 0

    override func initLogicalBoard() -> AbstractGameBoard {
        self.logicalBoardWidth = 7
        self.logicalBoardHeight = 8
        return SquareBoard(width: self.logicalBoardWidth, height: self.logicalBoardHeight)
    }
    
    override func setShapePaths() {
        
        squareWidth = size.width / CGFloat(self.logicalBoardWidth)
        totalHeight = CGFloat(self.logicalBoardHeight) * squareWidth
        let pipeWidth = squareWidth / 4.0
        
        var squarePath = CGPathCreateMutable()
        CGPathMoveToPoint(squarePath, nil, -squareWidth/2, -squareWidth/2)
        CGPathAddLineToPoint(squarePath, nil, squareWidth/2, -squareWidth/2)
        CGPathAddLineToPoint(squarePath, nil, squareWidth/2, squareWidth/2)
        CGPathAddLineToPoint(squarePath, nil, -squareWidth/2, squareWidth/2)
        CGPathCloseSubpath(squarePath)
        var transformScale = CGAffineTransformMakeScale(0.95, 0.95)
        squarePath = CGPathCreateMutableCopyByTransformingPath(squarePath, &transformScale)!
        self.shapePaths[.Square] = squarePath
        
        
        var squarePipePath = CGPathCreateMutable()
        CGPathMoveToPoint   (squarePipePath, nil, pipeWidth * (-1/2), squareWidth/2 - 0.5)
        CGPathAddLineToPoint(squarePipePath, nil, pipeWidth * (1/2), squareWidth/2 - 0.5)
        CGPathAddLineToPoint(squarePipePath, nil, pipeWidth * (1/2), 0)
        CGPathAddArc        (squarePipePath, nil, 0, 0, pipeWidth * (1/2), 0, CGFloat(M_PI), true)
        CGPathCloseSubpath  (squarePipePath)
        transformScale = CGAffineTransformMakeScale(1.0, 0.95)
        squarePipePath = CGPathCreateMutableCopyByTransformingPath(squarePipePath, &transformScale)!
        self.pipePaths[.Square] = squarePipePath
        
    }
    
    override func pieceToPoint(piece: Piece) -> CGPoint {
        let x = squareWidth/2 + (CGFloat(piece.col) * squareWidth)
        let y = squareWidth/2 + (CGFloat(piece.row) * squareWidth)
        return CGPoint(x: x, y: size.height - y - (size.height - totalHeight)/2)
    }
}

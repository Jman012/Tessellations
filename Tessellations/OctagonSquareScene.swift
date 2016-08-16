//
//  OctagonSquareScene.swift
//  Tessellations
//
//  Created by James Linnell on 7/18/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit
import SpriteKit

class OctagonSquareScene: AbstractGameBoardScene {
    
    var octagonRadius: CGFloat = 0
    var adjustedRadius: CGFloat = 0
    var squareWidth: CGFloat = 0
    var pipeWidth: CGFloat = 0
    var totalHeight: CGFloat = 0
    var totalWidth: CGFloat = 0
    
    override func initLogicalBoard() -> AbstractGameBoard {
        self.logicalBoardWidth = 7
        self.logicalBoardHeight = 11
        return OctagonSquareBoard(width: self.logicalBoardWidth, height: self.logicalBoardHeight)
    }
    
    override func setShapePaths() {
        self.octagonRadius = size.width / ceil(CGFloat(self.logicalBoardWidth) / 2.0) / 2.0
        
        totalWidth = size.width
        totalHeight = self.octagonRadius * 2 * ceil(CGFloat(self.logicalBoardHeight) / 2.0)
        if totalHeight > size.height {
            self.octagonRadius = size.height / ceil(CGFloat(self.logicalBoardHeight) / 2.0) / 2.0
            
            totalHeight = size.height
            totalWidth = self.octagonRadius * 2 * ceil(CGFloat(self.logicalBoardWidth) / 2.0)
        }
        
        self.adjustedRadius = octagonRadius + (octagonRadius * CGFloat(cos(0.degrees)) - octagonRadius * CGFloat(cos(22.5.degrees)))
        self.squareWidth = adjustedRadius * CGFloat(sin((45/2).degrees) * 2)
        self.pipeWidth = squareWidth / 2.5
        
        
        
        var octPath = CGPathCreateMutable()
        var angle = 45.0 / 2
        CGPathMoveToPoint(octPath, nil, self.adjustedRadius * CGFloat(cos(angle.degrees)), self.adjustedRadius * CGFloat(sin(angle.degrees)))
        for _ in 0..<7 {
            angle += 45.0
            CGPathAddLineToPoint(octPath, nil, self.adjustedRadius * CGFloat(cos(angle.degrees)), self.adjustedRadius * CGFloat(sin(angle.degrees)))
        }
        CGPathCloseSubpath(octPath)
        var transformScale = CGAffineTransformMakeScale(0.95, 0.95)
        octPath = CGPathCreateMutableCopyByTransformingPath(octPath, &transformScale)!
        self.shapePaths[.Octagon] = octPath
        
        var transform = CGAffineTransformMakeRotation(CGFloat(M_PI_4))
        var squarePath = CGPathCreateWithRect(CGRectMake(-self.squareWidth / 2, -self.squareWidth / 2, self.squareWidth, self.squareWidth), &transform)
        squarePath = CGPathCreateMutableCopyByTransformingPath(squarePath, &transformScale)!
        self.shapePaths[.Square45] = squarePath
        
        var octPipePath = CGPathCreateMutable()
        CGPathMoveToPoint   (octPipePath, nil, self.pipeWidth * (-1/2), self.octagonRadius - 0.5)
        CGPathAddLineToPoint(octPipePath, nil, self.pipeWidth * (1/2), self.octagonRadius - 0.5)
        CGPathAddLineToPoint(octPipePath, nil, self.pipeWidth * (1/2), 0)
        CGPathAddArc        (octPipePath, nil, 0, 0, self.pipeWidth * (1/2), 0, CGFloat(M_PI), true)
        CGPathCloseSubpath  (octPipePath)
        transformScale = CGAffineTransformMakeScale(1.0, 0.95)
        octPipePath = CGPathCreateMutableCopyByTransformingPath(octPipePath, &transformScale)!
        self.pipePaths[.Octagon] = octPipePath
        
        var squarePipePath = CGPathCreateMutable()
        CGPathMoveToPoint   (squarePipePath, nil, self.pipeWidth * (-1/2), self.squareWidth / 2)
        CGPathAddLineToPoint(squarePipePath, nil, self.pipeWidth * (1/2), self.squareWidth / 2)
        CGPathAddLineToPoint(squarePipePath, nil, self.pipeWidth * (1/2), 0)
        CGPathAddArc        (squarePipePath, nil, 0, 0, self.pipeWidth * (1/2), 0, CGFloat(M_PI), true)
        CGPathCloseSubpath  (squarePipePath)
        squarePipePath = CGPathCreateMutableCopyByTransformingPath(squarePipePath, &transformScale)!
        self.pipePaths[.Square45] = squarePipePath
        
    }
    
    override func pieceToPoint(piece: Piece) -> CGPoint {
        let x: CGFloat = self.octagonRadius + (CGFloat(piece.col) * self.octagonRadius)
        let y: CGFloat = self.octagonRadius + (CGFloat(piece.row) * self.octagonRadius)
        
        return CGPoint(x: x + (size.width - totalWidth)/2, y: size.height - y - (size.height - totalHeight)/2)
    }
}
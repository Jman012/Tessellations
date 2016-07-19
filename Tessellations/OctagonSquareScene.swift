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
    
    var octagonDiameter: CGFloat = 0
    var adjustedDiameter: CGFloat = 0
    var squareWidth: CGFloat = 0
    var pipeWidth: CGFloat = 0
    var boardFrame: CGRect = CGRect()
    
    required init(size: CGSize) {
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func initLogicalBoard() {
        self.logicalBoard = OctagonSquareBoard(width: self.logicalBoardWidth, height: self.logicalBoardHeight)
    }
    
    override func setShapePaths() {
        self.octagonDiameter = size.width / ceil(CGFloat(self.logicalBoardWidth) / 2.0) / 2.0
        self.adjustedDiameter = octagonDiameter + (octagonDiameter * CGFloat(cos(0.degrees)) - octagonDiameter * CGFloat(cos(22.5.degrees)))
        self.squareWidth = adjustedDiameter * CGFloat(sin((45/2).degrees) * 2)
        self.pipeWidth = squareWidth / 2.5
        
        
        
        var octPath = CGPathCreateMutable()
        var angle = 45.0 / 2
        CGPathMoveToPoint(octPath, nil, self.adjustedDiameter * CGFloat(cos(angle.degrees)), self.adjustedDiameter * CGFloat(sin(angle.degrees)))
        for _ in 0..<7 {
            angle += 45.0
            CGPathAddLineToPoint(octPath, nil, self.adjustedDiameter * CGFloat(cos(angle.degrees)), self.adjustedDiameter * CGFloat(sin(angle.degrees)))
        }
        CGPathCloseSubpath(octPath)
        var transformScale = CGAffineTransformMakeScale(0.95, 0.95)
        octPath = CGPathCreateMutableCopyByTransformingPath(octPath, &transformScale)!
        self.shapePaths[.Octagon] = octPath
        
        var transform = CGAffineTransformMakeRotation(CGFloat(M_PI_4))
        var squarePath = CGPathCreateWithRect(CGRectMake(-self.squareWidth / 2, -self.squareWidth / 2, self.squareWidth, self.squareWidth), &transform)
        squarePath = CGPathCreateMutableCopyByTransformingPath(squarePath, &transformScale)!
        self.shapePaths[.Square] = squarePath
        
        var octPipePath = CGPathCreateMutable()
        CGPathMoveToPoint   (octPipePath, nil, self.pipeWidth * (-1/2), self.octagonDiameter - 0.5)
        CGPathAddLineToPoint(octPipePath, nil, self.pipeWidth * (1/2), self.octagonDiameter - 0.5)
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
        self.pipePaths[.Square] = squarePipePath
        
        self.boardFrame = CGRect(x: 0,
                                 y: (self.frame.height - self.octagonDiameter * CGFloat(self.logicalBoardHeight)) / 2.0,
                                 width: self.octagonDiameter * 2 * CGFloat(self.logicalBoardWidth),
                                 height: self.octagonDiameter * 2 * CGFloat(self.logicalBoardHeight))
    }
    
    override func pieceToPoint(piece: Piece) -> CGPoint {
        let (row, col) = (piece.row, piece.col)
        
        if row % 2 == 0 && col % 2 == 0 {
            /* Octagon */
            return CGPoint(x: (CGFloat(col) * self.octagonDiameter) + self.octagonDiameter,
                           y: self.size.height - (CGFloat(row) * self.octagonDiameter) - self.octagonDiameter - self.boardFrame.origin.y)
        } else if row % 2 == 1 && col % 2 == 1 {
            /* Square */
            return CGPoint(x: (CGFloat(col) * self.octagonDiameter) + self.octagonDiameter,
                           y: self.size.height - (CGFloat(row) * self.octagonDiameter) - self.octagonDiameter - self.boardFrame.origin.y)
        } else {
            return CGPoint(x: 0, y: 0)
        }
    }
}
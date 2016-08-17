//
//  SquareTriangleCrazyScene.swift
//  Tessellations
//
//  Created by James Linnell on 8/10/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit
import SpriteKit

class SquareTriangleCrazyScene: AbstractGameBoardScene {

    var squareWidth: CGFloat = 0
    var tri_a: CGFloat = 0
    var tri_r: CGFloat = 0
    var tri_R: CGFloat = 0
    var totalHeight: CGFloat = 0
    
    override func initLogicalBoard() -> AbstractGameBoard {
        self.logicalBoardWidth = 12
        self.logicalBoardHeight = 12
        return SquareTriangleCrazyBoard(width: self.logicalBoardWidth, height: self.logicalBoardHeight)
    }
    
    override func setShapePaths() {
        
        squareWidth = 45.0
        var squarePath = CGPathCreateMutable()
        CGPathMoveToPoint(squarePath, nil, -squareWidth/2, -squareWidth/2)
        CGPathAddLineToPoint(squarePath, nil, squareWidth/2, -squareWidth/2)
        CGPathAddLineToPoint(squarePath, nil, squareWidth/2, squareWidth/2)
        CGPathAddLineToPoint(squarePath, nil, -squareWidth/2, squareWidth/2)
        CGPathCloseSubpath(squarePath)
        var transformScale = CGAffineTransformMakeScale(0.95, 0.95)
        squarePath = CGPathCreateMutableCopyByTransformingPath(squarePath, &transformScale)!
        self.shapePaths[.Square] = squarePath
        
        var transformRotate = CGAffineTransformMakeRotation(CGFloat(30.0.degrees))
        let square30Path = CGPathCreateMutableCopyByTransformingPath(squarePath, &transformRotate)
        self.shapePaths[.Square30] = square30Path
        
        let pipeWidth = squareWidth / 4.0
        var squarePipePath = CGPathCreateMutable()
        CGPathMoveToPoint   (squarePipePath, nil, pipeWidth * (-1/2), squareWidth/2 - 0.5)
        CGPathAddLineToPoint(squarePipePath, nil, pipeWidth * (1/2), squareWidth/2 - 0.5)
        CGPathAddLineToPoint(squarePipePath, nil, pipeWidth * (1/2), 0)
        CGPathAddArc        (squarePipePath, nil, 0, 0, pipeWidth * (1/2), 0, CGFloat(M_PI), true)
        CGPathCloseSubpath  (squarePipePath)
        transformScale = CGAffineTransformMakeScale(1.0, 0.95)
        squarePipePath = CGPathCreateMutableCopyByTransformingPath(squarePipePath, &transformScale)!
        self.pipePaths[.Square] = squarePipePath
        
        self.pipePaths[.Square30] = squarePipePath

        
        tri_a = squareWidth
        tri_r = tri_a * sqrt(3.0) / 6.0
        tri_R = tri_a * sqrt(3.0) / 3.0
        totalHeight = CGFloat(self.logicalBoardHeight) * (tri_r + tri_R)
        
        var triangleUpPath = CGPathCreateMutable()
        var angle = 90.0
        CGPathMoveToPoint(triangleUpPath, nil, tri_R * CGFloat(cos(angle.degrees)), tri_R * CGFloat(sin(angle.degrees)))
        for _ in 0..<2 {
            angle += 120.0
            CGPathAddLineToPoint(triangleUpPath, nil, tri_R * CGFloat(cos(angle.degrees)), tri_R * CGFloat(sin(angle.degrees)))
        }
        CGPathCloseSubpath(triangleUpPath)
        transformScale = CGAffineTransformMakeScale(0.95, 0.95)
        triangleUpPath = CGPathCreateMutableCopyByTransformingPath(triangleUpPath, &transformScale)!
        self.shapePaths[.TriangleUp] = triangleUpPath
        
        transformRotate = CGAffineTransformMakeRotation(CGFloat(90.0.degrees))
        var trianglePath = CGPathCreateMutableCopyByTransformingPath(triangleUpPath, &transformRotate)!
        self.shapePaths[.TriangleLeft] = trianglePath
        
        trianglePath = CGPathCreateMutableCopyByTransformingPath(trianglePath, &transformRotate)!
        self.shapePaths[.TriangleDown] = trianglePath
        
        trianglePath = CGPathCreateMutableCopyByTransformingPath(trianglePath, &transformRotate)!
        self.shapePaths[.TriangleRight] = trianglePath
        
        
        var trianglePipePath = CGPathCreateMutable()
        CGPathMoveToPoint   (trianglePipePath, nil, pipeWidth * (-1/2), tri_r - 0.5)
        CGPathAddLineToPoint(trianglePipePath, nil, pipeWidth * (1/2), tri_r - 0.5)
        CGPathAddLineToPoint(trianglePipePath, nil, pipeWidth * (1/2), 0)
        CGPathAddArc        (trianglePipePath, nil, 0, 0, pipeWidth * (1/2), 0, CGFloat(M_PI), true)
        CGPathCloseSubpath  (trianglePipePath)
        transformScale = CGAffineTransformMakeScale(1.0, 0.95)
        trianglePipePath = CGPathCreateMutableCopyByTransformingPath(trianglePipePath, &transformScale)!
        self.pipePaths[.TriangleUp] = trianglePipePath
        self.pipePaths[.TriangleDown] = trianglePipePath
        self.pipePaths[.TriangleLeft] = trianglePipePath
        self.pipePaths[.TriangleRight] = trianglePipePath
        
    }
    
    override func pieceToPoint(piece: Piece) -> CGPoint {
        // Get the steps up and left
        let (_, stepsUp, stepsLeft) = (self.logicalBoard as! SquareTriangleCrazyBoard).pieceTypeForRowCol(RowCol(row: piece.row, col: piece.col), stepsUp: 0, stepsLeft: 0)!
        var x: CGFloat, y: CGFloat
        
        // Starting points
        switch piece.type {
        case .Square30:
            x = (squareWidth * 0.5) + tri_r + tri_R
            y = tri_r
            x = x + (cos(CGFloat(150.0.degrees)) * (tri_r + (squareWidth*0.5)))
            y = y + (sin(CGFloat(150.0.degrees)) * (tri_r + (squareWidth*0.5)))
        case .Square:
            x = squareWidth + tri_r + tri_R
            y = (squareWidth * 0.5) + (tri_r + tri_R)
        case .TriangleUp:
            x = squareWidth + tri_r + tri_R
            y = tri_R
        case .TriangleDown:
            x = (squareWidth * 0.5) + tri_r + tri_R
            y = tri_r
        case .TriangleLeft:
            x = (squareWidth * 0.5) + tri_R
            y = (tri_r + tri_R) + (squareWidth * 0.5)
        case .TriangleRight:
            x = tri_r + tri_R + (squareWidth * 1.5) + tri_r
            y = tri_r + tri_R + (squareWidth * 0.5)
        default:
            x = 0
            y = 0
        }
        
        // Move them steps up and left
        x = x + (squareWidth * 0.5 * CGFloat(stepsUp))
        y = y + ((squareWidth + tri_r + tri_R) * CGFloat(stepsUp))
        
        x = x + ((squareWidth + tri_r + tri_R) * CGFloat(stepsLeft))
        y = y + (squareWidth * -0.5 * CGFloat(stepsLeft))


        return CGPoint(x: x, y: size.height - y - (size.height - totalHeight)/2)
    }
}

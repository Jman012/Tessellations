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

    var square: Square!
    var square30: Square30!
    var triangleUp: TriangleUp!
    var triangleDown: TriangleDown!
    var triangleLeft: TriangleLeft!
    var triangleRight: TriangleRight!
    
    var totalHeight: CGFloat = 0
    
    override func initLogicalBoard() -> AbstractGameBoard {
        self.logicalBoardWidth = 12
        self.logicalBoardHeight = 12
        return SquareTriangleCrazyBoard(width: self.logicalBoardWidth, height: self.logicalBoardHeight)
    }
    
    override func setShapePaths() {
        
        let squareWidth: CGFloat = 45.0
        let pipeWidth = squareWidth / 3.0
        
        square = Square(width: squareWidth, pipeWidth: pipeWidth)
        self.shapePaths[.Square] = square.path
        self.pipePaths[.Square] = square.pipePath
        
        square30 = Square30(width: squareWidth, pipeWidth: pipeWidth)
        self.shapePaths[.Square30] = square30.path
        self.pipePaths[.Square30] = square30.pipePath
        
        triangleUp = TriangleUp(sideLength: squareWidth, pipeWidth: pipeWidth)
        self.shapePaths[.TriangleUp] = triangleUp.path
        self.pipePaths[.TriangleUp] = triangleUp.pipePath
        
        triangleDown = TriangleDown(sideLength: squareWidth, pipeWidth: pipeWidth)
        self.shapePaths[.TriangleDown] = triangleDown.path
        self.pipePaths[.TriangleDown] = triangleDown.pipePath
        
        triangleLeft = TriangleLeft(sideLength: squareWidth, pipeWidth: pipeWidth)
        self.shapePaths[.TriangleLeft] = triangleLeft.path
        self.pipePaths[.TriangleLeft] = triangleLeft.pipePath
        
        triangleRight = TriangleRight(sideLength: squareWidth, pipeWidth: pipeWidth)
        self.shapePaths[.TriangleRight] = triangleRight.path
        self.pipePaths[.TriangleRight] = triangleRight.pipePath
        

        totalHeight = CGFloat(self.logicalBoardHeight) * (triangleUp.r + triangleUp.R)
        
    }
    
    override func pieceToPoint(piece: Piece) -> CGPoint {
        // Get the steps up and left
        let (_, stepsUp, stepsLeft) = (self.logicalBoard as! SquareTriangleCrazyBoard).pieceTypeForRowCol(RowCol(row: piece.row, col: piece.col), stepsUp: 0, stepsLeft: 0)!
        var x: CGFloat, y: CGFloat
        
        // Starting points
        switch piece.type {
        case .Square30:
            x = (square.width * 0.5) + triangleUp.r + triangleUp.R
            y = triangleUp.r
            x = x + (cos(CGFloat(150.0.degrees)) * (triangleUp.r + (square.width*0.5)))
            y = y + (sin(CGFloat(150.0.degrees)) * (triangleUp.r + (square.width*0.5)))
        case .Square:
            x = square.width + triangleUp.r + triangleUp.R
            y = (square.width * 0.5) + (triangleUp.r + triangleUp.R)
        case .TriangleUp:
            x = square.width + triangleUp.r + triangleUp.R
            y = triangleUp.R
        case .TriangleDown:
            x = (square.width * 0.5) + triangleUp.r + triangleUp.R
            y = triangleUp.r
        case .TriangleLeft:
            x = (square.width * 0.5) + triangleUp.R
            y = (triangleUp.r + triangleUp.R) + (square.width * 0.5)
        case .TriangleRight:
            x = triangleUp.r + triangleUp.R + (square.width * 1.5) + triangleUp.r
            y = triangleUp.r + triangleUp.R + (square.width * 0.5)
        default:
            x = 0
            y = 0
        }
        
        // Move them steps up and left
        x = x + (square.width * 0.5 * CGFloat(stepsUp))
        y = y + ((square.width + triangleUp.r + triangleUp.R) * CGFloat(stepsUp))
        
        x = x + ((square.width + triangleUp.r + triangleUp.R) * CGFloat(stepsLeft))
        y = y + (square.width * -0.5 * CGFloat(stepsLeft))


        return CGPoint(x: x, y: size.height - y - (size.height - totalHeight)/2)
    }
}

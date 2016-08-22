//
//  HexagonSquareTriangleScene.swift
//  Tessellations
//
//  Created by James Linnell on 8/18/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit
import SpriteKit

class HexagonSquareTriangleScene: AbstractGameBoardScene {

    var hexagon30: Hexagon30!
    var square: Square!
    var square30: Square30!
    var squareN30: SquareN30!
    var triangleUp: TriangleUp!
    var triangleDown: TriangleDown!
    
    var bandHeight: CGFloat {
        get { return hexagon30.cornerRadius + triangleUp.height - square.halfWidth }
    }
    var halfBandHeight: CGFloat {
        get { return bandHeight / 2.0 }
    }
    var totalHeight: CGFloat = 0
    var totalWidth: CGFloat = 0
    
    override func initLogicalBoard() -> AbstractGameBoard {
        self.logicalBoardWidth = 15
        self.logicalBoardHeight = 13
        return HexagonSquareTriangleBoard(width: self.logicalBoardWidth, height: self.logicalBoardHeight)
    }
    
    override func setShapePaths() {
        let effectiveWidth = size.width - self.margins.width*2
        let effectiveHeight = size.height - self.margins.height*2
        
        let hSteps = CGFloat(self.logicalBoardWidth - 3) / 4.0
//        let vSteps = CGFloat(self.logicalBoardHeight - 1) / 4.0
        
        /* The code is the reverse of the following line */
        /* totalWidth = (hexagon30.edgeRadius + square.width + hexagon30.edgeDiameter) + (hexagon30.edgeDiameter + square.width) * hSteps */
        let temp = 2.0 / sqrt(3.0)
        let hexagon30Width = CGFloat(2.0) * effectiveWidth / CGFloat(3.0 + temp + (2 + temp) * Double(hSteps))
//        let hexagon30Width: CGFloat = 50.0
        
        self.makeShapesForHexa30Width(hexagon30Width)
        
        totalWidth = effectiveWidth
        totalHeight = effectiveHeight
//        totalHeight = dodecagon.edgeDiameter + (vSteps * (2 * hexagon.edgeDiameter + square.width + dodecagon.edgeDiameter))
        
        if totalHeight > effectiveHeight {
            // Change the proportions to fit the screen is the original didn't fit nicely
            let percent = effectiveHeight / totalHeight
            
            totalWidth = totalWidth * percent
            totalHeight = effectiveHeight
            
            self.makeShapesForHexa30Width(hexagon30Width * percent)
        }
        
    }
    
    func makeShapesForHexa30Width(hexagon30Width: CGFloat) {
        let pipeWidth = hexagon30Width / 5.0
        
        hexagon30 = Hexagon30(edgeDiameter: hexagon30Width, pipeWidth: pipeWidth)
        self.shapePaths[.Hexagon30] = hexagon30.path
        self.pipePaths[.Hexagon30] = hexagon30.pipePath
        
        square = Square(width: hexagon30.sideLength, pipeWidth: pipeWidth)
        self.shapePaths[.Square] = square.path
        self.pipePaths[.Square] = square.pipePath
        
        square30 = Square30(width: hexagon30.sideLength, pipeWidth: pipeWidth)
        self.shapePaths[.Square30] = square30.path
        self.pipePaths[.Square30] = square30.pipePath
        
        squareN30 = SquareN30(width: hexagon30.sideLength, pipeWidth: pipeWidth)
        self.shapePaths[.SquareN30] = squareN30.path
        self.pipePaths[.SquareN30] = squareN30.pipePath
        
        triangleUp = TriangleUp(sideLength: hexagon30.sideLength, pipeWidth: pipeWidth)
        self.shapePaths[.TriangleUp] = triangleUp.path
        self.pipePaths[.TriangleUp] = triangleUp.pipePath
        
        triangleDown = TriangleDown(sideLength: hexagon30.sideLength, pipeWidth: pipeWidth)
        self.shapePaths[.TriangleDown] = triangleDown.path
        self.pipePaths[.TriangleDown] = triangleDown.pipePath
    }
    
    override func pieceToPoint(piece: Piece) -> CGPoint {
        let (row, col) = (piece.row, piece.col)
        var x: CGFloat = 0, y: CGFloat = 0
        
        if (row % 4 == 0 && col % 4 == 1) || (row % 4 == 2 && col % 4 == 3) || /* Hex 30 */
           (row % 4 == 0 && col % 4 == 3) || (row % 4 == 2 && col % 4 == 1) {  /* Square */
            /* BOTH Hexagon 30 Degrees AND Square (Regular) */
            x = (square.halfWidth + hexagon30.edgeRadius) + (square.halfWidth + hexagon30.edgeRadius) * CGFloat(col - 1) * 0.5
            y = hexagon30.cornerRadius + (hexagon30.cornerRadius + triangleUp.height + square.halfWidth) * (CGFloat(row) * 0.5)
            
        } else {
            /* Sq30, Sq-30, TUp, and TDown */
            x = (square.halfWidth + hexagon30.edgeRadius) * 0.5 + CGFloat(col) * (hexagon30.edgeRadius + square.halfWidth) * 0.5
            y = (hexagon30.cornerRadius + square.halfWidth + halfBandHeight) + CGFloat(row - 1) * 0.5 * (bandHeight + square.width)
            
            if (row % 4 == 1 && col % 4 == 1) || (row % 4 == 3 && col % 4 == 3) {
                /* Triangle Up */
                y = y + halfBandHeight - triangleUp.r
            } else if (row % 4 == 1 && col % 4 == 3) || (row % 4 == 3 && col % 4 == 1) {
                /* Triangle Down */
                y = y - halfBandHeight + triangleDown.r
            }
        }
        
        return CGPoint(x: x + (size.width - totalWidth)/2, y: size.height - y - (size.height - totalHeight)/2)
    }
}

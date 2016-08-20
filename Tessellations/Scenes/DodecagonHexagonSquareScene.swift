//
//  DodecagonHexagonSquareScene.swift
//  Tessellations
//
//  Created by James Linnell on 8/16/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit
import SpriteKit

class DodecagonHexagonSquareScene: AbstractGameBoardScene {

    var dodecagon: Dodecagon!
    var hexagon: Hexagon!
    var square: Square!
    var square30: Square30!
    var squareN30: SquareN30!
    
    var bandHeight: CGFloat {
        get { return dodecagon.edgeRadius - square.halfWidth }
    }
    var halfBandHeight: CGFloat {
        get { return bandHeight / 2.0 }
    }
    var totalHeight: CGFloat = 0
    var totalWidth: CGFloat = 0
    
    override func initLogicalBoard() -> AbstractGameBoard {
        self.logicalBoardWidth = 13
        self.logicalBoardHeight = 13
        return DodecagonHexagonSquareBoard(width: self.logicalBoardWidth, height: self.logicalBoardHeight)
    }
    
    override func setShapePaths() {
        
        let hSteps = CGFloat(self.logicalBoardWidth - 1) / 4.0
        let vSteps = CGFloat(self.logicalBoardHeight - 1) / 4.0
        
        /* The code is the reverse of the following line */
        /* totalWidth = dodecagon.edgeDiameter + (dodecagon.edgeDiameter + dodecagon.sideLength) * steps */
        let dodecagonEdgeDiameter = size.width / (1 + hSteps + 0.25*CGFloat(sqrt(6.0) - sqrt(2.0))*hSteps)
        
        self.makeShapesForDodecaEdgeDiameter(dodecagonEdgeDiameter)
        
        totalWidth = size.width
        totalHeight = dodecagon.edgeDiameter + (vSteps * (2 * hexagon.edgeDiameter + square.width + dodecagon.edgeDiameter))
        
        if totalHeight > size.height {
            // Change the proportions to fit the screen is the original didn't fit nicely
            let percent = size.height / totalHeight
            
            totalWidth = totalWidth * percent
            totalHeight = size.height
            
            self.makeShapesForDodecaEdgeDiameter(dodecagonEdgeDiameter * percent)
        }
        
    }
    
    func makeShapesForDodecaEdgeDiameter(dodecagonEdgeDiameter: CGFloat) {
        dodecagon = Dodecagon(edgeDiameter: dodecagonEdgeDiameter, pipeWidth: 0)
        dodecagon = Dodecagon(edgeDiameter: dodecagonEdgeDiameter, pipeWidth: dodecagon.sideLength / 3.0)
        self.shapePaths[.Dodecagon] = dodecagon.path
        self.pipePaths[.Dodecagon] = dodecagon.pipePath
        
        hexagon = Hexagon(triangleSide: dodecagon.sideLength, pipeWidth: dodecagon.sideLength / 3.0)
        self.shapePaths[.Hexagon] = hexagon.path
        self.pipePaths[.Hexagon] = hexagon.pipePath
        
        square = Square(width: dodecagon.sideLength, pipeWidth: dodecagon.sideLength / 3.0)
        self.shapePaths[.Square] = square.path
        self.pipePaths[.Square] = square.pipePath
        
        square30 = Square30(width: dodecagon.sideLength, pipeWidth: dodecagon.sideLength / 3.0)
        self.shapePaths[.Square30] = square30.path
        self.pipePaths[.Square30] = square30.pipePath
        
        squareN30 = SquareN30(width: dodecagon.sideLength, pipeWidth: dodecagon.sideLength / 3.0)
        self.shapePaths[.SquareN30] = squareN30.path
        self.pipePaths[.SquareN30] = squareN30.pipePath
    }
    
    override func pieceToPoint(piece: Piece) -> CGPoint {
        let (row, col) = (piece.row, piece.col)
        var x: CGFloat = 0, y: CGFloat = 0
        
        if (row % 4 == 0 && col % 4 == 0) || (row % 4 == 2 && col % 4 == 2) {
            /* Dodecagon */
            x = dodecagon.edgeRadius + (square.halfWidth + dodecagon.edgeRadius)*(CGFloat(col) / 2.0)
            y = dodecagon.edgeRadius + (dodecagon.edgeRadius + hexagon.edgeDiameter + square.halfWidth)*(CGFloat(row) / 2.0)
        } else if (row % 4 == 0 && col % 4 == 2) || (row % 4 == 2 && col % 4 == 0) {
            /* Square (Regular) */
            x = dodecagon.edgeRadius + (square.halfWidth + dodecagon.edgeRadius)*(CGFloat(col) / 2.0)
            y = dodecagon.edgeRadius + (dodecagon.edgeRadius + hexagon.edgeDiameter + square.halfWidth)*(CGFloat(row) / 2.0)
        } else if (row % 4 == 1 && col % 4 == 0) || (row % 4 == 3 && col % 4 == 0) ||
            (row % 4 == 1 && col % 4 == 2) || (row % 4 == 3 && col % 4 == 2) {
            /* Hexagons */
            x = dodecagon.edgeRadius + (CGFloat(col) * (dodecagon.edgeRadius + square.halfWidth) / 2.0)
            y = (dodecagon.edgeRadius + square.halfWidth + hexagon.edgeRadius + halfBandHeight) + (CGFloat(row-1) * (hexagon.edgeDiameter + square.width + bandHeight) / 2.0)
            if (row % 4 == 1 && col % 4 == 0) || (row % 4 == 3 && col % 4 == 2) {
                /* Move Down */
                y += halfBandHeight
            } else {
                /* Move Up */
                y -= halfBandHeight
            }
        } else if (row % 4 == 1 && col % 4 == 1) || (row % 4 == 3 && col % 4 == 3) {
            /* Square30 */
            x = dodecagon.edgeRadius + (CGFloat(col) * (dodecagon.edgeRadius + square.halfWidth) / 2.0)
            y = (dodecagon.edgeRadius + square.halfWidth + hexagon.edgeRadius + halfBandHeight) + (CGFloat(row-1) * (hexagon.edgeDiameter + square.width + bandHeight) / 2.0)
            
        } else if (row % 4 == 1 && col % 4 == 3) || (row % 4 == 3 && col % 4 == 1) {
            /* Square Opposite 30 (Negative) */
            x = dodecagon.edgeRadius + (CGFloat(col) * (dodecagon.edgeRadius + square.halfWidth) / 2.0)
            y = (dodecagon.edgeRadius + square.halfWidth + hexagon.edgeRadius + halfBandHeight) + (CGFloat(row-1) * (hexagon.edgeDiameter + square.width + bandHeight) / 2.0)

        }
        
        return CGPoint(x: x + (size.width - totalWidth)/2, y: size.height - y - (size.height - totalHeight)/2)
    }
}

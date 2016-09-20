//
//  DodecagonHexagonSquareScene.swift
//  Tessellations
//
//  Created by James Linnell on 8/16/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit
import SpriteKit

private let sizes: [(Int, Int)] = [
    (5, 5), /* Small */
    (9, 5), /* Medium */
    (13, 9), /* Large */
    (13, 13)/* Huge */
]

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
    
    override func initLogicalBoard(boardSize boardSize: BoardSize) -> AbstractGameBoard {
        (self.logicalBoardWidth, self.logicalBoardHeight) = sizes[boardSize.rawValue]
        return DodecagonHexagonSquareBoard(width: self.logicalBoardWidth, height: self.logicalBoardHeight)
    }
    
    override func initLogicalBoard() -> AbstractGameBoard {
        return DodecagonHexagonSquareBoard(width: self.logicalBoardWidth, height: self.logicalBoardHeight)
    }
    
    override class func size(boardSize: BoardSize) -> (Int, Int) {
        return sizes[boardSize.rawValue]
    }
    
    override func setShapePaths() {
        
//        let hSteps = CGFloat(self.logicalBoardWidth - 1) / 4.0
        let vSteps = CGFloat(self.logicalBoardHeight - 1) / 4.0
        let numEvenWidth = ceil(CGFloat(self.logicalBoardWidth) / 2.0)
        
        /* The code is the reverse of the following line */
        /* totalWidth = dodecagon.edgeDiameter + (dodecagon.edgeDiameter + dodecagon.sideLength) * steps */
//        let dodecagonEdgeDiameter = effectiveWidth / (1 + hSteps + 0.25*CGFloat(sqrt(6.0) - sqrt(2.0))*hSteps)
        let temp = 0.5 + (1.0 / (2.0*(2.0 + sqrt(3.0))))
        let denominator = (1.0 + (numEvenWidth - 1.0)*CGFloat(temp))
        let dodecagonEdgeDiameter = effectiveWidth / denominator
        
        self.makeShapesForDodecaEdgeDiameter(dodecagonEdgeDiameter)
        
        totalWidth = effectiveWidth
        totalHeight = dodecagon.edgeDiameter + (vSteps * (2 * hexagon.edgeDiameter + square.width + dodecagon.edgeDiameter))
        
        if totalHeight > effectiveHeight {
            // Change the proportions to fit the screen is the original didn't fit nicely
            let percent = effectiveHeight / totalHeight
            
            totalWidth = totalWidth * percent
            totalHeight = effectiveHeight
            
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
    
    override class func thumbnailScene(size: CGSize) -> AbstractGameBoardScene? {
        let scene = DodecagonHexagonSquareScene(size: size, boardWidth: 3, boardHeight: 2, thumbnailMode: true)
        
        scene.logicalBoard.board[1][0] = nil
        scene.logicalBoard.board[0][2] = nil
        
        scene.totalHeight -= scene.halfBandHeight
//        scene.totalWidth = scene.totalWidth - scene.dodecagon.edgeRadius + scene.hexagon.cornerRadius
        
        let denominator = 1.0 + (3 / (2.0*(2.0 + sqrt(3.0))))
        let dodecagonEdgeDiameter = size.width / CGFloat(denominator)
        scene.makeShapesForDodecaEdgeDiameter(dodecagonEdgeDiameter)
        scene.constructTextures()
        scene.refreshAllPieces()
        
        let dPiece = scene.logicalBoard.getPiece(row: 0, col: 0)!
        scene.logicalBoard.setPipeState(.Source, ofPiece: dPiece, inTrueDir: .SouthEastEast)
        
        let sPiece = scene.logicalBoard.getPiece(row: 1, col: 1)!
        scene.logicalBoard.setPipeState(.Source, ofPiece: sPiece, inTrueDir: .NorthEastEast)
        
        let hPiece = scene.logicalBoard.getPiece(row: 1, col: 2)!
        scene.logicalBoard.setPipeState(.Source, ofPiece: hPiece, inTrueDir: .NorthWestWest)
        scene.logicalBoard.setPipeState(.Source, ofPiece: hPiece, inTrueDir: .SouthWestWest)
        
        return scene
    }
}

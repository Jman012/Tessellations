//
//  OctagonSquareScene.swift
//  Tessellations
//
//  Created by James Linnell on 7/18/16.
//  Copyright © 2016 James Linnell. All rights reserved.
//

import UIKit
import SpriteKit

private let sizes: [(Int, Int)] = [
    (5, 5),  /* Small */
    (7, 9),  /* Medium */
    (9, 13), /* Large */
    (11, 15) /* Huge */
]

class OctagonSquareScene: AbstractGameBoardScene {
    
    var octagon: Octagon!
    var square45: Square45!
    
    override func initLogicalBoard(boardSize boardSize: BoardSize) -> AbstractGameBoard {
        (self.logicalBoardWidth, self.logicalBoardHeight) = sizes[boardSize.rawValue]
        return OctagonSquareBoard(width: self.logicalBoardWidth, height: self.logicalBoardHeight)
    }
    
    override func initLogicalBoard() -> AbstractGameBoard {
        return OctagonSquareBoard(width: self.logicalBoardWidth, height: self.logicalBoardHeight)
    }
    
    override func setShapePaths() {
        
        let octWide = ceil(CGFloat(self.logicalBoardWidth) / 2.0)
        let squWide = floor(CGFloat(self.logicalBoardWidth) / 2.0)
        let octTall = ceil(CGFloat(self.logicalBoardHeight) / 2.0)
        let squTall = floor(CGFloat(self.logicalBoardHeight) / 2.0)
        
        let temp = CGFloat(0.5 * sqrt(2.0) / (1.0 + sqrt(2.0)))
        var octagonEdgeDiameter: CGFloat = effectiveWidth / (1.0 + (squWide * temp) + (octWide-1.0)*(1.0 - temp))
        
        octagon = Octagon(edgeDiameter: octagonEdgeDiameter, pipeWidth: octagonEdgeDiameter / 5.0)
        square45 = Square45(width: octagon.sideLength, pipeWidth: octagonEdgeDiameter / 5.0)
        
        totalWidth = effectiveWidth
        totalHeight = octagon.edgeDiameter + (squTall * square45.diagonal / 2.0) + (octTall - 1.0)*(octagon.edgeDiameter - square45.diagonal/2.0)
        if totalHeight > effectiveHeight {
            
            let percent = effectiveHeight / totalHeight
            totalHeight = effectiveHeight
            totalWidth = totalWidth * percent
            
            octagonEdgeDiameter = octagonEdgeDiameter * percent
        }
        
        
        octagon = Octagon(edgeDiameter: octagonEdgeDiameter, pipeWidth: octagonEdgeDiameter / 5.0)
        self.shapePaths[.Octagon] = octagon.path
        self.pipePaths[.Octagon] = octagon.pipePath
        
        square45 = Square45(width: octagon.sideLength, pipeWidth: octagonEdgeDiameter / 5.0)
        self.shapePaths[.Square45] = square45.path
        self.pipePaths[.Square45] = square45.pipePath
        
    }
    
    override func pieceToPoint(piece: Piece) -> CGPoint {
        let x: CGFloat = octagon.edgeRadius + (CGFloat(piece.col) * octagon.edgeRadius)
        let y: CGFloat = octagon.edgeRadius + (CGFloat(piece.row) * octagon.edgeRadius)
        
        return CGPoint(x: x + (size.width - totalWidth)/2, y: size.height - y - (size.height - totalHeight)/2)
    }
    
    override class func thumbnailScene(size: CGSize) -> AbstractGameBoardScene? {
        
        let scene = OctagonSquareScene(size: size, boardWidth: 2, boardHeight: 2, margins: false)
        
        let oPiece = scene.logicalBoard.getPiece(row: 0, col: 0)!
        scene.logicalBoard.setPipeState(.Source, ofPiece: oPiece, inTrueDir: .SouthEast)
        
        let sPiece = scene.logicalBoard.getPiece(row: 1, col: 1)!
        scene.logicalBoard.setPipeState(.Source, ofPiece: sPiece, inTrueDir: .NorthWest)
        
        return scene
    }
}
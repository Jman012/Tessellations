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
    
    var square: Square!

    override func initLogicalBoard() -> AbstractGameBoard {
        return SquareBoard(width: self.logicalBoardWidth, height: self.logicalBoardHeight)
    }
    
    override func setShapePaths() {
        
        var squareWidth = effectiveWidth / CGFloat(self.logicalBoardWidth)
        totalHeight = CGFloat(self.logicalBoardHeight) * squareWidth
        totalWidth = effectiveWidth
        if totalHeight > effectiveHeight {
            squareWidth = effectiveHeight / CGFloat(self.logicalBoardHeight)
            totalHeight = effectiveHeight
            totalWidth = CGFloat(self.logicalBoardWidth) * squareWidth
        }
            
        square = Square(width: squareWidth, pipeWidth: squareWidth / 3)
        
        self.shapePaths[.Square] = square.path
        self.pipePaths[.Square] = square.pipePath
    
    }
    
    override func pieceToPoint(piece: Piece) -> CGPoint {
        let x = square.width/2 + (CGFloat(piece.col) * square.width)
        let y = square.width/2 + (CGFloat(piece.row) * square.width)
        return CGPoint(x: x + (size.width - totalWidth)/2, y: size.height - y - (size.height - totalHeight)/2)
    }
    
    override class func thumbnailScene(size: CGSize) -> AbstractGameBoardScene? {
        
        let scene = SquareScene(size: size, boardWidth: 1, boardHeight: 1, margins: false)
        
        let piece = scene.logicalBoard.getPiece(row: 0, col: 0)!
        scene.logicalBoard.setPipeState(.Source, ofPiece: piece, inTrueDir: .East)
        
        return scene
    }
    
}
